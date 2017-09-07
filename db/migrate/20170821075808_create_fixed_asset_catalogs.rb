class CreateFixedAssetCatalogs < ActiveRecord::Migration
  def change
    create_table :fixed_asset_catalogs do |t|
      t.string :code, :limit => 8, :null => false
      t.string :name, :null => false
      t.string :measurement_unit
      t.integer :years
      t.string :desc
      
      t.timestamps
    end
  end
end
