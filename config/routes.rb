Rails.application.routes.draw do
  root 'home#index'
  get 'home/new_trigger_message'
  get 'home/new_excel_gen'
  get 'home/new_source_trigger'
  post 'home/file_process_trigger'
  post 'home/process_excel'
  post 'home/process_sources_trigger'

  get 'elasticsearch/login', to: 'elastic_search#login'
  post 'elasticsearch/authenticate', to: 'elastic_search#authenticate'
  delete 'elasticsearch/logout', to: 'elastic_search#logout'

  get 'elasticsearch/choose_index', to: 'elastic_search#choose_index'

  get 'elasticsearch/search_form', to: 'elastic_search#search_form'
  delete 'elasticsearch/clear_search_session', to: 'elastic_search#clear_search_session'
  get 'elasticsearch/search_results', to: 'elastic_search#search_results'
  get 'elasticsearch/view_cluster', to: 'elastic_search#view_cluster'

  get 'saga_json/login', to: 'saga_json#login'
  post 'saga_json/authenticate', to: 'saga_json#authenticate'
  delete 'saga_json/logout', to: 'saga_json#logout'

  get 'saga_json/search_form', to: 'saga_json#search_form'
  delete 'saga_json/clear_search_session', to: 'saga_json#clear_search_session'
  get 'saga_json/search_results', to: 'saga_json#search_results'

  post 'saga_json/refresh_saga_data', to: 'saga_json#refresh_saga_data'
  post 'saga_json/download_saga_report', to: 'saga_json#download_saga_report'

  get 'result_hash/get_input', to: 'result_hash#get_input'
  post 'result_hash/process_input', to: 'result_hash#process_input'
  get 'result_hash/index', to: 'result_hash#index'
  delete 'result_hash/clear_result_hash', to: 'result_hash#clear_result_hash'
end
