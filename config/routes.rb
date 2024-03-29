ShpostAsset::Application.routes.draw do

  
  resources :rent_imgs

  scope 'shpost_asset' do
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
      get 'import'
      post 'import' => 'units#import'
    end
    resources :users, :controller => 'unit_users'
    resources :sequences, :controller => 'unit_sequences'
    member do 
      get 'index'
      get 'newsub'
      get 'update_unit'
      get 'destroy_unit'
    end
  end

  resources :users do
    collection do
      get 'import'
      post 'import' => 'users#import'
      get 'select_roles'
    end
    resources :roles, :controller => 'user_roles' do
      collection do
        get 'select_roles'
      end
    end
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
      post 'print'
      get 'fixed_asset_report'
      post 'fixed_asset_report_export'
      get 'reprint_import'
      post 'reprint_import' => 'fixed_asset_infos#reprint_import'
    end
    member do 
      get 'to_scan'
    end
  end

  # resources :low_value_consumption_infos do
  #   collection do
  #     post 'export'
  #   end
  # end

  resources :purchases do 
    collection do
      post 'do_send'
      get 'to_do_index'
      get 'doing_index'
      get 'done_index'
    end

    member do 
      get 'to_send'
      get 'to_check'
      get 'approve'
      get 'decline'
      get 'revoke'
      get 'cancel'
      get 'print'
      get 'print_certificate'
      get 'rent_print_certificate'
    end

    resources :low_value_consumption_infos, :controller => 'purchase_low_value_consumption_info' do
      collection do
        post 'batch_destroy'
        post 'batch_edit'
        post 'batch_update'
        post 'print'
        get 'import'
        post 'import' => 'purchase_low_value_consumption_info#import' 
      end
    end

    resources :rent_infos, :controller => 'purchase_rent_info' do
      collection do
        post 'batch_destroy'
        post 'batch_edit'
        post 'batch_update'
        post 'print'
        get 'import'
        post 'import' => 'purchase_rent_info#import' 
      end
    end
      
  end

  resources :low_value_consumption_infos do
    collection do
      get 'discard_index'
      get 'print'
      post 'print'  
      get 'batch_edit'
      post 'batch_edit'
      post 'batch_update'   
      get 'low_value_consumption_info_import'
      post 'low_value_consumption_info_import' => 'low_value_consumption_infos#low_value_consumption_info_import' 
      post 'batch_destroy'
      get 'discard'
      post 'discard'
      get 'low_value_consumption_report'
      post 'low_value_consumption_report_export'
      get 'lvc_report'
      post 'lvc_report'
      post 'lvc_report_export'
      get 'select_catalog2'
      post 'select_catalog2'
      get 'select_catalog3'
      post 'select_catalog3'
      get 'select_catalog4'
      post 'select_catalog4'
      get 'reprint_import'
      post 'reprint_import' => 'low_value_consumption_infos#reprint_import'
    end
    member do 
      get 'to_scan'
      # get 'discard'
    end
  end

  resources :unit_autocom do
    collection do
      get 'p_autocomplete_relevant_department_name'
      get 'p_autocomplete_use_unit_name'
      get 'p_autocomplete_send_unit_name'
      get 'p_autocomplete_low_value_consumption_parent_catalog'
      get 'p_autocomplete_low_value_consumption_catalog4'
      get 'si_autocomplete_fixed_asset_catalog'
      get 'si_autocomplete_low_value_consumption_catalog'
      get 'si_autocomplete_lv3_unit'
      get 'lvc_report_autocomplete_manage_unit'
      get 'p_autocomplete_fixed_asset_parent_catalog'
      get 'p_autocomplete_fixed_asset_catalog4'
    end
  end

  resources :fixed_asset_inventory_units

  resources :fixed_asset_inventory_details do
    member do
      get 'recheck'
      get 'scan'
      post 'match'
      post 'unmatch'
      post 'import'
    end
  end

  resources :fixed_asset_inventories do 
    collection do
      get 'level2_index'
      get 'doing_index'
      get 'to_sample_inventory'
      post 'sample_inventory'
      get 'sample_inventory_index'
      get 'sample_inventory_doing_index'
      get 'sample_level2_index'
    end

    member do 
      get 'cancel'
      get 'done'
      get 'sub_done'
      get 'to_report'
      post 'report'
      post 'export'
      get 'sample_report'
      post 'sample_report'
    end

    resources :fixed_asset_inventory_details, :controller => 'fixed_asset_inventory_fixed_asset_inventory_detail' do 
      collection do
        get 'doing_index'
      end

      
    end
  end 
  
  resources :low_value_consumption_inventory_details do
    member do
      get 'recheck'
      get 'scan'
      post 'match'
      post 'unmatch'
      post 'import'
    end
  end

  resources :low_value_consumption_inventory_units

  resources :low_value_consumption_inventories do 
    collection do
      get 'level2_index'
      get 'doing_index'
      get 'to_sample_inventory'
      post 'sample_inventory'
      get 'sample_inventory_index'
      get 'sample_inventory_doing_index'
      get 'sample_level2_index'
    end

    member do 
      get 'cancel'
      get 'done'
      get 'sub_done'
      get 'to_report'
      post 'report'
      post 'export'
      get 'sample_report'
      post 'sample_report'
    end

    resources :low_value_consumption_inventory_details, :controller => 'low_value_consumption_inventory_low_value_consumption_inventory_detail' do 
      collection do
        get 'doing_index'
      end

      
    end
  end 

  resources :lvc_discard_details

  resources :lvc_discards do
    member do 
      get 'approve'
      get 'decline'
    end

    resources :lvc_discard_details, :controller => 'lvc_discard_lvc_discard_detail'
  end

  resources :up_downloads do
    collection do 
      get 'up_download_import'
      post 'up_download_import' => 'up_downloads#up_download_import'
      
      get 'to_import'
      
      
    end
    member do
      get 'up_download_export'
      post 'up_download_export' => 'up_downloads#up_download_export'
    end
  end

  resources :rent_infos do
    collection do
      get 'discard_index'
      get 'print'
      post 'print'  
      get 'batch_edit'
      post 'batch_edit'
      post 'batch_update'   
      get 'rent_info_import'
      post 'rent_info_import' => 'rent_infos#rent_info_import' 
      post 'batch_destroy'
      get 'discard'
      post 'discard'
      get 'rent_report'
      post 'rent_report'
      post 'rent_report_export'
      get 'select_catalog2'
      post 'select_catalog2'
      get 'select_catalog3'
      post 'select_catalog3'
      get 'select_catalog4'
      post 'select_catalog4'
      get 'reprint_import'
      post 'reprint_import' => 'rent_infos#reprint_import'
      get 'import'
      post 'import' => 'rent_infos#import'
    end
    member do 
      get 'to_scan'
      # get 'discard'
    end
  end


  resources :rent_inventory_units

  resources :rent_inventory_details do
    member do
      get 'recheck'
      get 'scan'
      post 'match'
      post 'unmatch'
      post 'import'
    end
  end

  resources :rent_inventories do 
    collection do
      get 'level2_index'
      get 'doing_index'
      get 'to_sample_inventory'
      post 'sample_inventory'
      get 'sample_inventory_index'
      get 'sample_inventory_doing_index'
      get 'sample_level2_index'
    end

    member do 
      get 'cancel'
      get 'done'
      get 'sub_done'
      get 'to_report'
      post 'report'
      post 'export'
      get 'sample_report'
      post 'sample_report'
    end

    resources :rent_inventory_details, :controller => 'rent_inventory_rent_inventory_detail' do 
      collection do
        get 'doing_index'
      end     
    end
  end 

  resources :user_messages do
    collection do 
      post 'set_is_read'
    end
  end

  resources :messages do 
    collection do 
      get 'report'
      post 'report'
      post 'report_export'
    end
  end

  resources :activate_assets do
    member do
      get 'download'
      post 'download' => 'activate_assets#download'
      get 'done'
    end
  end

  resources :import_files do
    collection do 
      get 'import'
      post 'import' => 'import_files#import'
    end
  end

end
end
