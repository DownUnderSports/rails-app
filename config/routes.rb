Rails.application.routes.draw do
  root to: "home#show"
  resource :session, only: %i[ new create destroy ]
  resources :users, only: %i[ new create ]

  get '*path', to: "home#not_found", constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
end
