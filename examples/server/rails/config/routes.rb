Rails.application.routes.draw do
  devise_for :users, :skip => [:omniauth_callbacks], :controllers => {registrations: 'registrations'}

  devise_scope :user do
    match "/users/auth/:provider(/:sub_provider)",
          constraints: { provider: /oauthio/ },
          to: "users/omniauth_callbacks#passthru",
          as: :omniauth_authorize,
          via: [:get, :post]

    match "/users/auth/:action(/:sub_provider)/callback",
          constraints: { action: /oauthio/, sub_provider: /twitter|google/ },
          to: "users/omniauth_callbacks",
          as: :omniauth_callback,
          via: [:get, :post]
  end

  api_version(:module => 'Api::V1', :path => {:value => 'api/v1'}, :defaults => {:format => :json}, :default => true) do
    get '/profile' => 'user#profile'
  end
end
