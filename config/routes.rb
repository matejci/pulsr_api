Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get '/dropbox-webhook' => 'dropbox#confirm_token'
  post '/dropbox-webhook' => 'dropbox#update'

  require 'sidekiq/api'
  get "queue-status" => proc {
    [200, {
      "Content-Type" => "text/plain"
    }, [Sidekiq::Queue.new.size < 1000 ? "OK" : "UHOH" ]]
  }

  namespace :api do
    resources :users do
      member do
        get 'saved'
        put 'block'
      end
    end

    resources :events do
      collection do
        resources :posts

        resources :tags do
          member do
            post 'add'
            post 'remove'
          end
        end

        post 'save', action: 'save', kind: 'save'
        post 'remove', action: 'save', kind: 'remove'
        post 'hide', action: 'hide', kind: 'hide'
        post 'unhide', action: 'hide', kind: 'unhide'
        get 'saved'
        get 'hidden'
        post 'add_photos'
        post 'remove_photos'
        post 'add_photo', action: 'add_photos'
        post 'remove_photo', action: 'remove_photos'
      end

      resources :photos
      resources :posts

      resources :tags do
        member do
          post 'add'
          post 'remove'
        end
      end

      member do
        post 'save', action: 'save', kind: 'save'
        post 'remove', action: 'save', kind: 'remove'
        post 'hide', action: 'hide', kind: 'hide'
        post 'unhide', action: 'hide', kind: 'unhide'
        get 'saved'
        get 'going'
        get 'hidden'
        post 'add_photos'
        post 'remove_photos'
        post 'add_photo', action: 'add_photos'
        post 'remove_photo', action: 'remove_photos'
      end

    end

    resources :venues do
      collection do
        resources :photos
        resources :posts

        resources :tags do
          member do
            post 'add'
            post 'remove'
          end
        end

        post 'save', action: 'save', kind: 'save'
        post 'remove', action: 'save', kind: 'remove'
        post 'hide', action: 'hide', kind: 'hide'
        post 'unhide', action: 'hide', kind: 'unhide'
        get 'saved'
        get 'hidden'
      end

      resources :photos
      resources :posts

      resources :tags do
        member do
          post 'add'
          post 'remove'
        end
      end

      member do
        post 'save', action: 'save', kind: 'save'
        post 'remove', action: 'save', kind: 'remove'
        post 'hide', action: 'hide', kind: 'hide'
        post 'unhide', action: 'hide', kind: 'unhide'
        get 'saved'
        get 'hidden'
      end
    end

    resources :photos do
      member do
        post 'report'
      end
    end
    resources :tags

    resources :posts do
      member do
        put 'report'
      end
    end
    resources :tastes, only: [:index, :create, :destroy]

    resources :users, only: [] do
      resources :posts, only: [:update, :destroy, :show] do
      end
    end

    resources :notifications, only: [:index, :update]

    resources :friendships, only: [:index, :create, :destroy] do
      collection do
        get 'pending'
        get 'requested'
      end
    end

    resources :points_of_interests, :only => :update

    get 'search' => 'searches#show'
    post 'autocomplete' => 'searches#show', autocomplete: true

    post 'contacts' => 'contacts#check'
    get 'contacts' => 'contacts#index'

    get 'explore' => 'explore#index'
    get 'recommend' => 'explore#recommend'

    get 'ping' => 'base#ping'
    post 'activity' => 'tweet_activity#index'

    post 'delete_user' => 'users#destroy'

  end
  get '/ping' => 'api/tweet_activity#ping'

  devise_for :users, controllers: {
    passwords: 'users/passwords'
  }

  devise_scope :user do
    get 'reset_password_success' => 'users/passwords#success'

    post 'api/reset_password' => 'users/passwords#create'

    namespace :api do
      resources :devices, only: [:index, :create]
      delete 'devices' => 'devices#destroy'

      resource :account, only: [] do
        get 'events' => 'events#index', defaults: { show_user_events: true }
        get 'saved_events' => 'events#user_saved'
        get 'hidden_events' => 'events#user_hidden'
        get 'saved' => 'explore#saved'
        get 'tastes' => 'tastes#user_tastes'
        post 'tastes' => 'tastes#update_user_tastes'
        delete 'tastes/:id' => 'tastes#destroy'
      end

      post 'report' => 'report#create'

      post 'invite' => 'invitations#create'
      post 'save', controller: 'explore', action: 'save', kind: 'save'
      post 'remove', controller: 'explore', action: 'save', kind: 'remove'
      post 'hide', controller: 'explore', action: 'hide', kind: 'hide'
      post 'unhide', controller: 'explore', action: 'hide', kind: 'unhide'
      post 'going', controller: 'explore', action: 'going', kind: 'going'
      post 'not_going', controller: 'explore', action: 'going', kind: 'not_going'
      post 'dismiss_going', controller: 'explore', action: 'going', kind: 'pending'
      post 'like', controller: 'explore', action: 'vote', vote: 'like'
      post 'dislike', controller: 'explore', action: 'vote', vote: 'dislike'
      post 'dismiss_like', controller: 'explore', action: 'vote', vote: 'pending'


      get 'account' => 'account#show'
      post 'account' => 'account#update'
      post 'confirm_code' => 'account#confirm_code'
      post 'authentication' => 'sessions#authentication'
      post 'register' => 'registration#create'
      post 'sign_in' => 'sessions#create'
      post 'facebook_sign_in' => 'sessions#facebook_create'
      post 'sign_out' => 'sessions#destroy'
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
