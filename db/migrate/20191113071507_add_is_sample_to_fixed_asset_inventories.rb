class AddIsSampleToFixedAssetInventories < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_inventories, :is_sample, :boolean, default: false
  end
end
