class SagaJsonController < ApplicationController

  def login
  end

  def authenticate
    # begin

      res = get_sagas_api(params[:api_url], params[:api_key])
      if res.success?
        create_session(params)
        flash[:notice] = "Connection Successful"
        redirect_to saga_json_search_form_path
      else
        flash[:alert] = "Connection Failed try again"
        redirect_to saga_json_login_path
      end
    # rescue
    #   flash[:alert] = "Connection Failed try again"
    #   redirect_to elasticsearch_login_path(params[:auth])
    # end
  end

  def logout
    delete_session
    flash[:notice] = "Logout Successful"
    redirect_to root_path
  end

  def search_form
    # binding.pry
  end

  def search_results
    sagas = get_sagas_api(session[:saga_json_url], session[:saga_json_key])
    input_sessions = %i[inputSjSource inputSjPlanYear inputSjBatchId inputSjStatus inputSjEntityType]
    input_sessions.map { |input| session[input] = params[input] }

    conditions = {}

    conditions['sourceKey'] = params[:inputSjSource] if params[:inputSjSource].present?
    conditions['batchId'] = params[:inputSjBatchId] if params[:inputSjBatchId].present?
    conditions['status'] = params[:inputSjStatus] if params[:inputSjStatus].present?

    result = sagas.map do |each_json|
      each_json if conditions.all? { |field, value| each_json[field].eql?(value) }
    end
    result.compact!

    if params[:inputSjPlanYear].present?
      result = result.map { |each_json| each_json if each_json.dig('attrs','planYear')&.eql?(params[:inputSjPlanYear]) }
    end
    result.compact!

    if params[:inputSjEntityType].present?
      result = result.map do |each_json|
        if params[:inputSjEntityType].downcase == 'both'
          each_json if each_json['fileContains']&.include?('provider') && each_json['fileContains']&.include?('organization')
        else
          each_json if each_json['fileContains']&.include?(params[:inputSjEntityType])
        end
      end
    end
    result.compact!
    @result = result.sort_by { |hash| DateTime.parse(hash['createdTs']) }.reverse
  end

  def clear_search_session
    input_sessions = %w[inputSjSource inputSjPlanYear inputSjBatchId inputSjStatus inputSjEntityType]
    input_sessions.map { |input| session[input] = nil }
    render status: :ok, body: nil
  end

  private

  def get_sagas_api(url, key)
    end_point = "#{url}/api/Saga"
    HTTParty.get(end_point, {
      headers: {
        'accept' => 'application/json',
        'x-functions-key' => key.to_s,
      }
    })
  end

  def create_session(params)
    session[:saga_json_url] = params[:api_url]
    session[:saga_json_key] = params[:api_key]
    session[:logged_in] = true

    session[:elastic_username] = nil
    session[:elastic_password] = nil
    session[:elastic_ip] = nil
  end

  def delete_session
    session[:saga_json_url] = nil
    session[:saga_json_key] = nil
    session[:logged_in] = false
  end

  def logged_in?
    session[:saga_json_url].present? && session[:saga_json_key].present? && session[:logged_in].to_s == 'true'
  end

end
