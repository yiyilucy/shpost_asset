class AddIsRentToLowValueConsumptionInfos < ActiveRecord::Migration
  def change
  	add_column :low_value_consumption_infos, :is_rent, :boolean, default: false
  end
end
