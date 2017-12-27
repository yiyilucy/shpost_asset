class CreateLvcDiscardDetails < ActiveRecord::Migration
  def change
    create_table :lvc_discard_details do |t|
      t.string :lvc_discard_id
      t.string :low_value_consumption_info_id
      
      t.timestamps
    end
  end
end
