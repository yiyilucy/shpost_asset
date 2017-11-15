class CreateLowValueConsumptionInventoryDetails < ActiveRecord::Migration
  def change
    create_table :low_value_consumption_inventory_details do |t|
      t.string :sn
      t.string :asset_name, :null => false
      t.string :asset_no
      t.integer :lvc_catalog_id, :null => false
      t.integer :relevant_unit_id
      t.datetime :buy_at
      t.datetime :use_at
      t.string :measurement_unit
      t.float :sum
      t.integer :use_unit_id
      t.string :branch
      t.string :location
      t.string :user
      t.string :change_log
      t.string :consumption_status
      t.integer :print_times
      t.string :brand_model
      t.string :batch_no
      t.integer :purchase_id
      t.integer :manage_unit_id
      t.integer :lvc_inventory_id
      t.string :inventory_status
      t.boolean :is_check, default: false
      t.string :desc
      t.integer :lvc_inventory_unit_id
      t.integer :low_value_consumption_info_id
      

      t.timestamps
    end
  end
end
