class AddColumnsToFixedAssetInventoryDetail < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_inventory_details, :brand_model, :string
  	add_column :fixed_asset_inventory_details, :use_years, :string
  	add_column :fixed_asset_inventory_details, :desc1, :string
  	add_column :fixed_asset_inventory_details, :belong_unit, :string
  end
end
