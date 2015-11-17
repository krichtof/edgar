
Edgar::Application.routes.draw do
  get "backdoor/play1"
  get "backdoor/play2"
  get "backdoor/play3"
  get "tags/index"
  

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/  do
    authenticated :user do
      root :to => 'home#index'
      get "search/index"
    end

    devise_scope :user do
      root :to => "showcase#index", :as => "locale_root", constraints: {subdomain: 'www'}
      match '/user/confirmation' => 'confirmations#update', :via => :put, :as => :update_user_confirmation
      match '', to: 'sessions#new', constraints: {subdomain: /.+/}
      get "features", to: "showcase#features"
      get "about", to: "showcase#about"
    end

    devise_for :users, :controllers => { :registrations => "registrations", :confirmations => "confirmations", :sessions => "sessions"}
    match 'users/bulk_invite/:quantity' => 'users#bulk_invite', :via => :get, :as => :bulk_invite
    resources :users do
      get 'invite', :on => :member
    end

    get "welcome", to: "welcome#index"
    get "home", to: "home#index"
    get "dashboard", to: "dashboard#index"

    resources :structures do
      put 'people/:id/set_main_person', action: :set_main_person, as: :set_main_person
      resources :people
    end
    resources :people_structures, only: [:create]
    resources :festivals
    resources :show_buyers
    resources :venues do
      resources :people
      resources :tasks do
        put 'complete', :on => :member
        put 'uncomplete', :on => :member
      end
    end
    resources :people do
      resources :tasks do
        put 'complete', :on => :member
        put 'uncomplete', :on => :member
      end
    end
    resources :tasks do
      put 'complete', :on => :member
      put 'uncomplete', :on => :member
    end
    resources :contacts do
      get 'autocomplete', on: :collection
      put 'bulk', on: :collection
      resources :tasks do
        put 'complete', :on => :member
        put 'uncomplete', :on => :member
      end

      get 'only/:filter', action: :only, on: :collection, as: :only
      get 'add_to_favorites', on: :member
      get 'remove_to_favorites', on: :member
      get 'show_map', on: :collection
    end
    resource :account do
      put 'import_samples', action: :import_samples, as: :import_samples
      delete 'destroy_test_contacts', action: :destroy_test_contacts

      resources :abilitations
    end
    resources :reportings

    resources :campaigns
    resources :opportunities

    resources :projects

    resources :styles, only: [:index]
    resources :networks, only: [:index]
    resources :customs, only: [:index]

    resources :jobs, only: [:show]

    resources :contacts_imports, only: [:new, :create, :update]
    get 'contacts_imports/new_with_details', to: 'contacts_imports#new_with_details', as: :new_with_details_contacts_import

    resources :contacts_exports, only: [:new]

    resources :announcements, only: [:index]
    resources :coupons
    resources :addresses, only: [:update]
    
    resource :subscription, only: [:new, :edit, :create, :update]
    
  end

  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  root to: redirect("/#{I18n.default_locale}")
end
