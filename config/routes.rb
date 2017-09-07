ShpostAsset::Application.routes.draw do
  
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
  root 'welcome#index'

  devise_for :users, controllers: { sessions: "users/sessions" }

  resources :user_logs, only: [:index, :show, :destroy]

  resources :units do
    collection do
      # get 'select_level3_parents'
      post 'update_unit_info'
    end
    resources :users, :controller => 'unit_users'
    member do 
      get 'index'
      get 'newsub'
      get 'update_unit'
      get 'destroy_unit'
    end
  end

  resources :users do
     resources :roles, :controller => 'user_roles'
  end

  resources :fixed_asset_catalogs do
    collection do
      get 'fixed_asset_catalog_import'
      post 'fixed_asset_catalog_import' => 'fixed_asset_catalogs#fixed_asset_catalog_import'
    end
  end

  resources :low_value_consumption_catalogs do
    collection do
      get 'low_value_consumption_catalog_import'
      post 'low_value_consumption_catalog_import' => 'low_value_consumption_catalogs#low_value_consumption_catalog_import'
    end
  end

  resources :fixed_asset_infos do
    collection do
      get 'fixed_asset_info_import'
      post 'fixed_asset_info_import' => 'fixed_asset_infos#fixed_asset_info_import'
      post 'export'
    end
  end

  # resources :low_value_consumption_infos do
  #   collection do
  #     post 'export'
  #   end
  # end

end
