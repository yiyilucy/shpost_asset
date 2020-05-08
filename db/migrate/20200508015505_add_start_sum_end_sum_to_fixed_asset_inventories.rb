class AddStartSumEndSumToFixedAssetInventories < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_inventories, :start_sum, :float
  	add_column :fixed_asset_inventories, :end_sum, :float
  end
end
