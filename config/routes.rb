Rails.application.routes.draw do
  root 'home#index'
  get 'home/new_trigger_message'
  get 'home/new_excel_gen'
  post 'home/file_process_trigger'
  post 'home/process_excel'
end
