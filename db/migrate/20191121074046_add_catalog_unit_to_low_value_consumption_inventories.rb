class AddCatalogUnitToLowValueConsumptionInventories < ActiveRecord::Migration
  def change
  	add_column :lvc_inventories, :lvc_catalog_id, :integer
  	add_column :lvc_inventories, :sample_unit_id, :integer
  end
end
