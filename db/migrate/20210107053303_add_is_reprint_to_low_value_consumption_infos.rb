class AddIsReprintToLowValueConsumptionInfos < ActiveRecord::Migration
  def change
  	add_column :low_value_consumption_infos, :is_reprint, :boolean, default: false
  end
end
