class AddIndexToLowValueConsumptionInfos < ActiveRecord::Migration
  def change
  	add_index :low_value_consumption_infos, :asset_no, :unique => true
  end
end
