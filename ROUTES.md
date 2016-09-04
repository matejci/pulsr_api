                  Prefix Verb   URI Pattern                                     Controller#Action
             sidekiq_web        /sidekiq                                        Sidekiq::Web
         dropbox_webhook GET    /dropbox-webhook(.:format)                      dropbox#confirm_token
                         POST   /dropbox-webhook(.:format)                      dropbox#update
        api_event_photos GET    /api/events/:event_id/photos(.:format)          api/photos#index
                         POST   /api/events/:event_id/photos(.:format)          api/photos#create
     new_api_event_photo GET    /api/events/:event_id/photos/new(.:format)      api/photos#new
    edit_api_event_photo GET    /api/events/:event_id/photos/:id/edit(.:format) api/photos#edit
         api_event_photo GET    /api/events/:event_id/photos/:id(.:format)      api/photos#show
                         PATCH  /api/events/:event_id/photos/:id(.:format)      api/photos#update
                         PUT    /api/events/:event_id/photos/:id(.:format)      api/photos#update
                         DELETE /api/events/:event_id/photos/:id(.:format)      api/photos#destroy
         api_event_posts GET    /api/events/:event_id/posts(.:format)           api/posts#index
                         POST   /api/events/:event_id/posts(.:format)           api/posts#create
      new_api_event_post GET    /api/events/:event_id/posts/new(.:format)       api/posts#new
     edit_api_event_post GET    /api/events/:event_id/posts/:id/edit(.:format)  api/posts#edit
          api_event_post GET    /api/events/:event_id/posts/:id(.:format)       api/posts#show
                         PATCH  /api/events/:event_id/posts/:id(.:format)       api/posts#update
                         PUT    /api/events/:event_id/posts/:id(.:format)       api/posts#update
                         DELETE /api/events/:event_id/posts/:id(.:format)       api/posts#destroy
       add_api_event_tag POST   /api/events/:event_id/tags/:id/add(.:format)    api/tags#add
    remove_api_event_tag POST   /api/events/:event_id/tags/:id/remove(.:format) api/tags#remove
          api_event_tags GET    /api/events/:event_id/tags(.:format)            api/tags#index
                         POST   /api/events/:event_id/tags(.:format)            api/tags#create
       new_api_event_tag GET    /api/events/:event_id/tags/new(.:format)        api/tags#new
      edit_api_event_tag GET    /api/events/:event_id/tags/:id/edit(.:format)   api/tags#edit
           api_event_tag GET    /api/events/:event_id/tags/:id(.:format)        api/tags#show
                         PATCH  /api/events/:event_id/tags/:id(.:format)        api/tags#update
                         PUT    /api/events/:event_id/tags/:id(.:format)        api/tags#update
                         DELETE /api/events/:event_id/tags/:id(.:format)        api/tags#destroy
          like_api_event POST   /api/events/:id/like(.:format)                  api/events#vote {:vote=>"like"}
       dislike_api_event POST   /api/events/:id/dislike(.:format)               api/events#vote {:vote=>"dislike"}
          save_api_event POST   /api/events/:id/save(.:format)                  api/events#save {:kind=>"save"}
        remove_api_event POST   /api/events/:id/remove(.:format)                api/events#save {:kind=>"remove"}
          hide_api_event POST   /api/events/:id/hide(.:format)                  api/events#hide {:kind=>"hide"}
        unhide_api_event POST   /api/events/:id/unhide(.:format)                api/events#hide {:kind=>"unhide"}
         saved_api_event GET    /api/events/:id/saved(.:format)                 api/events#saved
        hidden_api_event GET    /api/events/:id/hidden(.:format)                api/events#hidden
              api_events GET    /api/events(.:format)                           api/events#index
                         POST   /api/events(.:format)                           api/events#create
           new_api_event GET    /api/events/new(.:format)                       api/events#new
          edit_api_event GET    /api/events/:id/edit(.:format)                  api/events#edit
               api_event GET    /api/events/:id(.:format)                       api/events#show
                         PATCH  /api/events/:id(.:format)                       api/events#update
                         PUT    /api/events/:id(.:format)                       api/events#update
                         DELETE /api/events/:id(.:format)                       api/events#destroy
        api_venue_photos GET    /api/venues/:venue_id/photos(.:format)          api/photos#index
                         POST   /api/venues/:venue_id/photos(.:format)          api/photos#create
     new_api_venue_photo GET    /api/venues/:venue_id/photos/new(.:format)      api/photos#new
    edit_api_venue_photo GET    /api/venues/:venue_id/photos/:id/edit(.:format) api/photos#edit
         api_venue_photo GET    /api/venues/:venue_id/photos/:id(.:format)      api/photos#show
                         PATCH  /api/venues/:venue_id/photos/:id(.:format)      api/photos#update
                         PUT    /api/venues/:venue_id/photos/:id(.:format)      api/photos#update
                         DELETE /api/venues/:venue_id/photos/:id(.:format)      api/photos#destroy
         api_venue_posts GET    /api/venues/:venue_id/posts(.:format)           api/posts#index
                         POST   /api/venues/:venue_id/posts(.:format)           api/posts#create
      new_api_venue_post GET    /api/venues/:venue_id/posts/new(.:format)       api/posts#new
     edit_api_venue_post GET    /api/venues/:venue_id/posts/:id/edit(.:format)  api/posts#edit
          api_venue_post GET    /api/venues/:venue_id/posts/:id(.:format)       api/posts#show
                         PATCH  /api/venues/:venue_id/posts/:id(.:format)       api/posts#update
                         PUT    /api/venues/:venue_id/posts/:id(.:format)       api/posts#update
                         DELETE /api/venues/:venue_id/posts/:id(.:format)       api/posts#destroy
       add_api_venue_tag POST   /api/venues/:venue_id/tags/:id/add(.:format)    api/tags#add
    remove_api_venue_tag POST   /api/venues/:venue_id/tags/:id/remove(.:format) api/tags#remove
          api_venue_tags GET    /api/venues/:venue_id/tags(.:format)            api/tags#index
                         POST   /api/venues/:venue_id/tags(.:format)            api/tags#create
       new_api_venue_tag GET    /api/venues/:venue_id/tags/new(.:format)        api/tags#new
      edit_api_venue_tag GET    /api/venues/:venue_id/tags/:id/edit(.:format)   api/tags#edit
           api_venue_tag GET    /api/venues/:venue_id/tags/:id(.:format)        api/tags#show
                         PATCH  /api/venues/:venue_id/tags/:id(.:format)        api/tags#update
                         PUT    /api/venues/:venue_id/tags/:id(.:format)        api/tags#update
                         DELETE /api/venues/:venue_id/tags/:id(.:format)        api/tags#destroy
          save_api_venue POST   /api/venues/:id/save(.:format)                  api/venues#save {:kind=>"save"}
        remove_api_venue POST   /api/venues/:id/remove(.:format)                api/venues#save {:kind=>"remove"}
          hide_api_venue POST   /api/venues/:id/hide(.:format)                  api/venues#hide {:kind=>"hide"}
        unhide_api_venue POST   /api/venues/:id/unhide(.:format)                api/venues#hide {:kind=>"unhide"}
         saved_api_venue GET    /api/venues/:id/saved(.:format)                 api/venues#saved
        hidden_api_venue GET    /api/venues/:id/hidden(.:format)                api/venues#hidden
              api_venues GET    /api/venues(.:format)                           api/venues#index
                         POST   /api/venues(.:format)                           api/venues#create
           new_api_venue GET    /api/venues/new(.:format)                       api/venues#new
          edit_api_venue GET    /api/venues/:id/edit(.:format)                  api/venues#edit
               api_venue GET    /api/venues/:id(.:format)                       api/venues#show
                         PATCH  /api/venues/:id(.:format)                       api/venues#update
                         PUT    /api/venues/:id(.:format)                       api/venues#update
                         DELETE /api/venues/:id(.:format)                       api/venues#destroy
              api_photos GET    /api/photos(.:format)                           api/photos#index
                         POST   /api/photos(.:format)                           api/photos#create
           new_api_photo GET    /api/photos/new(.:format)                       api/photos#new
          edit_api_photo GET    /api/photos/:id/edit(.:format)                  api/photos#edit
               api_photo GET    /api/photos/:id(.:format)                       api/photos#show
                         PATCH  /api/photos/:id(.:format)                       api/photos#update
                         PUT    /api/photos/:id(.:format)                       api/photos#update
                         DELETE /api/photos/:id(.:format)                       api/photos#destroy
                api_tags GET    /api/tags(.:format)                             api/tags#index
                         POST   /api/tags(.:format)                             api/tags#create
             new_api_tag GET    /api/tags/new(.:format)                         api/tags#new
            edit_api_tag GET    /api/tags/:id/edit(.:format)                    api/tags#edit
                 api_tag GET    /api/tags/:id(.:format)                         api/tags#show
                         PATCH  /api/tags/:id(.:format)                         api/tags#update
                         PUT    /api/tags/:id(.:format)                         api/tags#update
                         DELETE /api/tags/:id(.:format)                         api/tags#destroy
           api_user_post GET    /api/users/:user_id/posts/:id(.:format)         api/posts#show
                         PATCH  /api/users/:user_id/posts/:id(.:format)         api/posts#update
                         PUT    /api/users/:user_id/posts/:id(.:format)         api/posts#update
                         DELETE /api/users/:user_id/posts/:id(.:format)         api/posts#destroy
             api_explore GET    /api/explore(.:format)                          api/explore#index
                api_ping GET    /api/ping(.:format)                             api/base#ping
            api_activity POST   /api/activity(.:format)                         api/tweet_activity#index
                    ping GET    /ping(.:format)                                 api/tweet_activity#ping
        new_user_session GET    /users/sign_in(.:format)                        devise/sessions#new
            user_session POST   /users/sign_in(.:format)                        devise/sessions#create
    destroy_user_session DELETE /users/sign_out(.:format)                       devise/sessions#destroy
           user_password POST   /users/password(.:format)                       devise/passwords#create
       new_user_password GET    /users/password/new(.:format)                   devise/passwords#new
      edit_user_password GET    /users/password/edit(.:format)                  devise/passwords#edit
                         PATCH  /users/password(.:format)                       devise/passwords#update
                         PUT    /users/password(.:format)                       devise/passwords#update
cancel_user_registration GET    /users/cancel(.:format)                         devise/registrations#cancel
       user_registration POST   /users(.:format)                                devise/registrations#create
   new_user_registration GET    /users/sign_up(.:format)                        devise/registrations#new
  edit_user_registration GET    /users/edit(.:format)                           devise/registrations#edit
                         PATCH  /users(.:format)                                devise/registrations#update
                         PUT    /users(.:format)                                devise/registrations#update
                         DELETE /users(.:format)                                devise/registrations#destroy
      events_api_account GET    /api/account/events(.:format)                   api/events#index {:show_user_events=>true}
             api_account GET    /api/account(.:format)                          api/account#show
                         POST   /api/account(.:format)                          api/account#update
      api_authentication POST   /api/authentication(.:format)                   api/sessions#authentication
            api_register POST   /api/register(.:format)                         api/registration#create
             api_sign_in POST   /api/sign_in(.:format)                          api/sessions#create
    api_facebook_sign_in POST   /api/facebook_sign_in(.:format)                 api/sessions#facebook_create
            api_sign_out POST   /api/sign_out(.:format)                         api/sessions#destroy
