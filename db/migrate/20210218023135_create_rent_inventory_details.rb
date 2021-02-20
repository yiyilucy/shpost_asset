class CreateRentInventoryDetails < ActiveRecord::Migration
  def change
    create_table :rent_inventory_details do |t|
      t.string :asset_no, :null => false
      t.string :asset_name
      t.integer :fixed_asset_catalog_id, :null => false
      t.datetime :use_at
      t.integer :amount
      t.string :brand_model
      t.string :use_user
      t.integer :use_unit_id
      t.string :location
      t.string :area
      t.float :sum
      t.datetime :use_right_start
      t.datetime :use_right_end
      t.string :pay_cycle
      t.string :license
      t.float :deposit
      t.integer :relevant_unit_id     
      t.string :rent_status
      t.integer :print_times
      t.integer :purchase_id
      t.integer :manage_unit_id
      t.string :ori_asset_no
      t.string :desc
      t.string :change_log
      t.integer :rent_info_id
      t.integer :rent_inventory_id
      t.string :inventory_status
      t.boolean :is_check, default: false
      t.integer :rent_inventory_unit_id
      t.integer :inventory_user_id
      t.datetime :end_date

      t.timestamps
    end
  end
end
