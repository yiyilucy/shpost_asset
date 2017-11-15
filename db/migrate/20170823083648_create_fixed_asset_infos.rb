class CreateFixedAssetInfos < ActiveRecord::Migration
  def change
    create_table :fixed_asset_infos do |t|
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
      t.string :status
      t.integer :print_times
      
      t.timestamps
    end
  end
end
