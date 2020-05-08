class AddStartSumEndSumToLowValueConsumptionInventories < ActiveRecord::Migration
  def change
  	add_column :lvc_inventories, :start_sum, :float
  	add_column :lvc_inventories, :end_sum, :float
  end
end
