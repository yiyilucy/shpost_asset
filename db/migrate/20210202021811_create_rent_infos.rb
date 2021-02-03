class CreateRentInfos < ActiveRecord::Migration
  def change
    create_table :rent_infos do |t|
      t.string :asset_no
      t.string :asset_name, :null => false
      t.integer :fixed_asset_catalog_id, :null => false
      t.datetime :use_at
      t.integer :amount
      t.string :brand_model
      t.string :use_user
      t.integer :use_unit_id
      t.string :location
      t.float :area
      t.float :sum
      t.datetime :use_right_start
      t.datetime :use_right_end
      t.string :pay_cycle
      t.string :license
      t.float :deposit
      t.integer :relevant_unit_id     
      t.string :status
      t.integer :print_times
      t.integer :purchase_id
      t.integer :manage_unit_id
      t.string :log
      t.datetime :discard_at
      t.boolean :is_reprint, default: false

      t.timestamps
    end
  end
end
