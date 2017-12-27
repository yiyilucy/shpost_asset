class CreateLvcDiscards < ActiveRecord::Migration
  def change
    create_table :lvc_discards do |t|
      t.string :name
      t.string :status
      t.integer :create_user_id
      t.integer :create_unit_id
      t.integer :checked_user_id
      t.string :desc

      t.timestamps
    end
  end
end
