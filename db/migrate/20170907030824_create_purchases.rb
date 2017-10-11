class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.string :no,    :null => false
      t.string :name
      t.string :status
      t.integer :create_user_id
      t.integer :create_unit_id
      t.integer :manage_unit_id
      t.boolean :is_send, default: false
      t.integer :to_check_user_id
      t.integer :checked_user_id
      t.string :change_log
      t.string :desc
      t.integer :use_unit_id

      t.timestamps
    end
  end
end
