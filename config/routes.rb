require "sidekiq/web"
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"
Rails.application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'
  namespace :api do
    namespace :v1 do
      resources :posts do
        mount V1::Comments => '/'

      end

      devise_for :users, controllers: {
        sessions: "users/sessions",
        registrations: "users/registrations"
      }

    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
