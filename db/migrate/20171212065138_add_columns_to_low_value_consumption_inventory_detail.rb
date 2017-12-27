class AddColumnsToLowValueConsumptionInventoryDetail < ActiveRecord::Migration
  def change
  	add_column :lvc_inventory_details, :use_years, :string
  	add_column :lvc_inventory_details, :desc1, :string
  end
end
