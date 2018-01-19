class AddInventoryUserToFixedAssetInventoryDetail < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_inventory_details, :inventory_user_id, :integer
  end
end
