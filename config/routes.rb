Rails.application.routes.draw do
  namespace :api do
    namespace 'v1' do
      resources :bids, only: [:create]
    end
  end
end
