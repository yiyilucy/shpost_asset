class ChangeLogToLowValueConsumptionInfo < ActiveRecord::Migration
  def up
  	change_column :low_value_consumption_infos, :log, :string, :limit => 4000
  end

  def down
  	change_column :low_value_consumption_infos, :log, :string
  end
end
