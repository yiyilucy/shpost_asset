class CreateActivateAssets < ActiveRecord::Migration
  def change
    create_table :activate_assets do |t|
			t.string :name
    	t.integer :create_user_id
      t.integer :create_unit_id
      t.string :contact,    :null => false
      t.string :tel,    :null => false
      t.text :introduce,    :null => false
      t.string :status, default: "valid"
      t.integer :import_file_id, :null => false
      
      t.timestamps
    end
  end
end
