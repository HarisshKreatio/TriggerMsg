class ElasticSearchController < ApplicationController

  def login
    redirect_to elasticsearch_choose_index_path if logged_in?
    @auth = params[:auth].present? && params[:auth].to_s == 'true'
  end

  def logout
    delete_session
    reset_chewy_client
    flash[:notice] = "Logout Successful"
    redirect_to root_path
  end

  def authenticate
    set_chewy_client(params)
    begin
      Chewy.client.cluster.health
      create_session(params)
      flash[:notice] = "Connection Successful"
      redirect_to elasticsearch_choose_index_path
    rescue
      flash[:alert] = "Connection Failed try again"
      redirect_to elasticsearch_login_path(params[:auth])
    end
  end

  def choose_index
    redirect_to elasticsearch_login_path unless logged_in?

    tenants = %w[leaporbit wahbe centerlight riverspring honestmedical mddoh]
    pr_indexes = %w[provider_tenant_rw practitioner_role_tenant_rw]
    fac_indexes = %w[facility_tenant_rw organization_affiliation_tenant_rw practice_tenant_rw]
    @provider_indexes = []
    @facility_indexes = []

    pr_indexes.each do |index|
      tenants.each do |tenant|
        @provider_indexes << index.gsub('tenant', tenant)
      end
    end

    fac_indexes.each do |index|
      tenants.each do |tenant|
        @facility_indexes << index.gsub('tenant', tenant)
      end
    end
  end

  def search_form
    session[:index_name] = params[:index_name] if params[:index_name]
    set_chewy_client_for_execution(session[:elastic_ip], session[:elastic_username], session[:elastic_password])
    BaseModel.index_name(session[:index_name])
    @doc_count = BaseModel.exists? ? BaseModel.count : "Index doesn't exist"
  end

  def clear_search_session
    input_sessions = %w[inputName inputNpi inputSource inputUpdatedDate inputStableId inputLocStableId inputAddrText inputAddrCity inputAddrState inputAddrZip inputSize]
    input_sessions.map { |input| session[input] = nil }
    render status: :ok, body: nil
  end

  def search_results
    input_sessions = %i[inputName inputNpi inputSource inputUpdatedDate inputStableId inputLocStableId inputAddrText inputAddrCity inputAddrState inputAddrZip inputSize]
    input_sessions.map { |input| session[input] = params[input] }
    params[:inputSize] = 10000
    search_query = form_elastic_query(params)
    set_chewy_client_for_execution(session[:elastic_ip], session[:elastic_username], session[:elastic_password])
    BaseModel.index_name(session[:index_name])
    @response = Chewy.client.search(index: session[:index_name], body: search_query)
    @matched_doc_count = @response['hits']['total']['value']
    @matched_doc = @response['hits']['hits']
  end

  private

  def set_chewy_client_for_execution(elastic_ip, username, password)
    if elastic_ip && username && password
      Chewy.settings = { host: elastic_ip , user: username, password: password, request_timeout: 7 }
      Chewy.current[:chewy_client] = Chewy::ElasticClient.new
    else
      Chewy.settings = { host: elastic_ip, request_timeout: 7 }
      Chewy.current[:chewy_client] = Chewy::ElasticClient.new
    end
  end

  def set_chewy_client(params)
    ip_address = params[:ip_address]
    port = params[:port]
    username = params[:username]
    password = params[:password]
    elastic_ip = "#{params[:ip_address]}:#{params[:port]}"

    if ip_address && port && username && password
      Chewy.settings = { host: elastic_ip , user: username, password: password, request_timeout: 7 }
      Chewy.current[:chewy_client] = Chewy::ElasticClient.new
    else
      Chewy.settings = { host: elastic_ip, request_timeout: 7 }
      Chewy.current[:chewy_client] = Chewy::ElasticClient.new
    end
  end

  def reset_chewy_client
    Chewy.settings = { host: session[:elastic_ip] }
    Chewy.current[:chewy_client] = Chewy::ElasticClient.new
  end

  def create_session(params)
    session[:elastic_username] = params[:username]
    session[:elastic_password] = params[:password]
    session[:elastic_ip] = "#{params[:ip_address]}:#{params[:port]}"
    session[:logged_in] = true
  end

  def delete_session
    session[:elastic_username] = nil
    session[:elastic_password] = nil
    session[:elastic_ip] = nil
    session[:logged_in] = false
  end

  def logged_in?
    session[:elastic_ip].present? && session[:logged_in].present? && session[:logged_in].to_s == 'true'
  end

  def form_elastic_query(params)
    # binding.pry
    must = []
    must << ElasticSearchHelper::Facility.name(params[:inputName]) if params[:inputName].present?
    must << ElasticSearchHelper::Facility.identifier(params[:inputNpi]) if params[:inputNpi].present?
    
    must << ElasticSearchHelper::Facility.source_name(params[:inputSource]) if params[:inputSource].present?
    must << ElasticSearchHelper::Facility.updated_date(params[:inputUpdatedDate]) if params[:inputUpdatedDate].present?
    must << ElasticSearchHelper::Facility.stable_id(params[:inputStableId]) if params[:inputStableId].present?

    must << ElasticSearchHelper::Facility.loc_stable_id(params[:inputLocStableId]) if params[:inputLocStableId].present?
    must << ElasticSearchHelper::Facility.address_text(params[:inputAddrText]) if params[:inputAddrText].present?
    must << ElasticSearchHelper::Facility.address_city(params[:inputAddrCity]) if params[:inputAddrCity].present?
    must << ElasticSearchHelper::Facility.address_state(params[:inputAddrState]) if params[:inputAddrState].present?
    must << ElasticSearchHelper::Facility.address_zip(params[:inputAddrZip]) if params[:inputAddrZip].present?

    if must.present?
      {
        "size": params[:inputSize],
        "query": {
          "nested": {
            "path": "organizationAffiliation",
            "query": {
              "bool": {
                "must": must
              }
            }
          }
        }
      }
    else
      {
        "size": params[:inputSize],
        "query": {
          "match_all": {}
        }
      }
    end

  end

end
