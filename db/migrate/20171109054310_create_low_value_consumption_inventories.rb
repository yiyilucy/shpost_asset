class CreateLowValueConsumptionInventories < ActiveRecord::Migration
  def change
    create_table :lvc_inventories do |t|
      t.string :no
      t.string :name
      t.string :desc
      t.string :status
      t.integer :create_user_id
      t.integer :create_unit_id
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :is_lv2_unit, default: false

      t.timestamps
    end
  end
end
