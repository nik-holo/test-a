Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :stats, only: %i[index]
      resources :links, only: %i[create]
      resources :images, path: 'images' do
        collection do
          get  ':uuid',  action: :show
          delete  ':uuid',  action: :destroy
          # ooh, look what you made me do :|
          post 'upload/:token', action: :create , token: /[^\/]+/
        end
      end
    end
  end
end
