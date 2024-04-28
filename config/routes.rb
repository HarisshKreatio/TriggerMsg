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

end
