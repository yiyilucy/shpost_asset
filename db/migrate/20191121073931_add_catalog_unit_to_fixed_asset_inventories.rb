class AddCatalogUnitToFixedAssetInventories < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_inventories, :fixed_asset_catalog_id, :integer
  	add_column :fixed_asset_inventories, :sample_unit_id, :integer
  end
end
