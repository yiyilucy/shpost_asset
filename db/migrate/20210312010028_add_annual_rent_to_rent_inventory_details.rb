class AddAnnualRentToRentInventoryDetails < ActiveRecord::Migration
  def change
  	add_column :rent_inventory_details, :annual_rent, :float
  end
end
