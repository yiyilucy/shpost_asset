class AddLogToLowValueConsumptionInfo < ActiveRecord::Migration
  def change
  	add_column :low_value_consumption_infos, :log, :string
  end
end
