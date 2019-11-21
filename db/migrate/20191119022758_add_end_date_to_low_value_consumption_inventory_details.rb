class AddEndDateToLowValueConsumptionInventoryDetails < ActiveRecord::Migration
  def change
  	add_column :lvc_inventory_details, :end_date, :datetime
  end
end
