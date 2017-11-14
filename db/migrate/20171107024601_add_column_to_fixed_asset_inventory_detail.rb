class AddColumnToFixedAssetInventoryDetail < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_inventory_details, :fixed_asset_inventory_unit_id, :integer
  	add_column :fixed_asset_inventory_details, :fixed_asset_info_id, :integer
  end
end
