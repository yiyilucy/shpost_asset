class CreateRentInventories < ActiveRecord::Migration
  def change
    create_table :rent_inventories do |t|
      t.string :no
      t.string :name
      t.string :desc
      t.string :status
      t.integer :create_user_id
      t.integer :create_unit_id
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :is_lv2_unit, default: false
      t.string :relevant_unit_ids
      t.boolean :is_sample, default: false
      t.integer :fixed_asset_catalog_id
      t.integer :sample_unit_id

      t.timestamps
    end
  end
end
