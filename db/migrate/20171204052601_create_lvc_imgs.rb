class CreateLvcImgs < ActiveRecord::Migration
  def change
    create_table :lvc_imgs do |t|
      t.integer :lvc_inventory_detail_id
      t.integer :low_value_consumption_info_id
      t.string :img_url
      
      t.timestamps
    end
  end
end
