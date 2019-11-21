class AddEndDateToFixedAssetInventoryDetails < ActiveRecord::Migration
  def change
  	add_column :fixed_asset_inventory_details, :end_date, :datetime
  end
end
