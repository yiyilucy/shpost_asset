class CreateFixedAssetInfos < ActiveRecord::Migration
  def change
    create_table :fixed_asset_infos do |t|
      t.string :sn
      t.string :asset_name
      t.string :asset_no
      t.string :catalog_name
      t.string :catalog_code, :limit => 8
      t.string :relevant_department
      t.datetime :buy_at
      t.datetime :use_at
      t.string :unit
      t.integer :amount
      t.float :price
      t.string :use_department
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
