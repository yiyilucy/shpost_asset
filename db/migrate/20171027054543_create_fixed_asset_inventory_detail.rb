class CreateFixedAssetInventoryDetail < ActiveRecord::Migration
  def change
    create_table :fixed_asset_inventory_details do |t|
   	  t.string :sn
      t.string :asset_name
      t.string :asset_no, :null => false
      t.integer :fixed_asset_catalog_id, :null => false
      t.string :relevant_department
      t.datetime :buy_at
      t.datetime :use_at
      t.string :measurement_unit
      t.integer :amount
      t.float :sum
      t.integer :unit_id, :null => false
      t.string :branch
      t.string :location
      t.string :user
      t.string :change_log
      t.string :accounting_department
      t.string :asset_status
      t.integer :print_times
      t.integer :manage_unit_id
      t.integer :fixed_asset_inventory_id
      t.string :inventory_status
      t.boolean :is_check, default: false
      t.string :desc

      t.timestamps
    end
  end
end
