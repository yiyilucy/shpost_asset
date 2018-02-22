class AddRelevantUnitIdsToFixedAssetInventory < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_inventories, :relevant_unit_ids, :string
  end
end
