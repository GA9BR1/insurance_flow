Rails.application.routes.draw do
  get 'policies/:id', to: 'policies#show'
end
