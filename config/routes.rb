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

end
