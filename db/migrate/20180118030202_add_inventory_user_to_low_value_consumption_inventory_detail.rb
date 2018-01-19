class AddInventoryUserToLowValueConsumptionInventoryDetail < ActiveRecord::Migration
  def change
  	add_column :lvc_inventory_details, :inventory_user_id, :integer
  end
end
