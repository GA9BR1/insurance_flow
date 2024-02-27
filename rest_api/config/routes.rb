Rails.application.routes.draw do
  get 'policies/:id', to: 'policies#show'
  get 'policies', to: 'policies#index'
end
