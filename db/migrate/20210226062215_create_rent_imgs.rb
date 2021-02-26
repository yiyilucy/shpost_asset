class CreateRentImgs < ActiveRecord::Migration
  def change
    create_table :rent_imgs do |t|
      t.integer :rent_inventory_detail_id
      t.integer :rent_info_id
      t.string :img_url

      t.timestamps
    end
  end
end
