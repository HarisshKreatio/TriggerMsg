class ElasticSearchController < ApplicationController
  def login
  end

  def logout
    session[:elastic_username] = nil
    session[:elastic_password] = nil
    session[:elastic_ip] = nil
    Chewy.settings = { host: session[:elastic_ip] }
    Chewy.current[:chewy_client] = Chewy::ElasticClient.new
    flash[:notice] = "Logout successful"
    redirect_to root_path
  end

  def authenticate
    if params[:ip_address] && params[:port] && params[:username] && params[:password]
      session[:elastic_username] = params[:username]
      session[:elastic_password] = params[:password]
      session[:elastic_ip] = "#{params[:ip_address]}:#{params[:port]}"
    elsif params[:ip_address]
      Chewy.settings = { host: "#{params[:ip_address]}:#{params[:port]}", request_timeout: 7 }
      Chewy.current[:chewy_client] = Chewy::ElasticClient.new
      begin
        Chewy.client.cluster.health
        session[:elastic_ip] = params[:ip_address]
        flash[:notice] = "Connection successful"
        redirect_to root_path
      rescue
        flash[:alert] = "Connection Failed try again"
        redirect_to elasticsearch_login_path
      end
    end
  end
end
