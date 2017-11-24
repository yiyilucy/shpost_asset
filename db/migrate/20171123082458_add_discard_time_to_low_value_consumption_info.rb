class AddDiscardTimeToLowValueConsumptionInfo < ActiveRecord::Migration
  def change
  	add_column :low_value_consumption_infos, :discard_at, :datetime
  end
end
