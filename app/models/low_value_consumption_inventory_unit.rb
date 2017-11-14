class LowValueConsumptionInventoryUnit < ActiveRecord::Base
	belongs_to :low_value_consumption_inventory
	has_many :low_value_consumption_inventory_details

	STATUS = { unfinished: '未完成', finished: '完成'}

	def status_name
		status.blank? ? "" : LowValueConsumptionInventoryUnit::STATUS["#{status}".to_sym]
	end
end
