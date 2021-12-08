class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
    	t.string :title
    	t.integer :activate_asset_id
    	t.boolean :is_release, default: true

      t.timestamps
    end
  end
end
