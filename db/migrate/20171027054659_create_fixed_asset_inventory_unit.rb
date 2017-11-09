class CreateFixedAssetInventoryUnit < ActiveRecord::Migration
  def change
    create_table :fixed_asset_inventory_units do |t|
      t.integer :unit_id
      t.integer :fixed_asset_inventory_id
      t.string :status

      t.timestamps
    end
  end
end
