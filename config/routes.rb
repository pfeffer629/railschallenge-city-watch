Rails.application.routes.draw do
  resources :emergencies, defaults: { format: :json }
  resources :responders, defaults: { format: :json }
end
