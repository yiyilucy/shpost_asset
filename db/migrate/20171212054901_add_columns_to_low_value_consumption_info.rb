class AddColumnsToLowValueConsumptionInfo < ActiveRecord::Migration
  def change
  	add_column :low_value_consumption_infos, :use_years, :string
  	add_column :low_value_consumption_infos, :desc1, :string
  end
end
