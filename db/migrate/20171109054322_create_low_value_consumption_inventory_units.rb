class CreateLowValueConsumptionInventoryUnits < ActiveRecord::Migration
  def change
    create_table :lvc_inventory_units do |t|
      t.integer :unit_id
      t.integer :lvc_inventory_id
      t.string :status

      t.timestamps
    end
  end
end
