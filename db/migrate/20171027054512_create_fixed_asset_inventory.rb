class CreateFixedAssetInventory < ActiveRecord::Migration
  def change
    create_table :fixed_asset_inventories do |t|
      t.string :no
      t.string :name
      t.string :desc
      t.string :status
      t.integer :create_user_id
      t.integer :create_unit_id
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
