class CreateFixedAssetImg < ActiveRecord::Migration
  def change
    create_table :fixed_asset_imgs do |t|
      t.integer :fa_inventory_detail_id
      t.integer :fixed_asset_info_id
      t.string :img_url
      
      t.timestamps
    end
  end
end
