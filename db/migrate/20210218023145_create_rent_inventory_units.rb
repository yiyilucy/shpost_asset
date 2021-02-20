class CreateRentInventoryUnits < ActiveRecord::Migration
  def change
    create_table :rent_inventory_units do |t|
      t.integer :unit_id
      t.integer :rent_inventory_id
      t.string :status

      t.timestamps
    end
  end
end
