class AddColumnToFixedAssetInventory < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_inventories, :is_lv2_unit, :boolean, default: false
  end
end
