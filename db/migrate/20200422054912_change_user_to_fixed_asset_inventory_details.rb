class ChangeUserToFixedAssetInventoryDetails < ActiveRecord::Migration
  def up
    rename_column :fixed_asset_inventory_details, :user, :use_user
  end

  def down
    rename_column :fixed_asset_inventory_details, :use_user, :user
  end
end
