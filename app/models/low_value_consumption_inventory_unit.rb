class LowValueConsumptionInventoryUnit < ActiveRecord::Base
	self.table_name = "lvc_inventory_units"
	belongs_to :low_value_consumption_inventory, class_name: 'LowValueConsumptionInventory', foreign_key: "lvc_inventory_id"
	
	has_many :low_value_consumption_inventory_details, inverse_of: :low_value_consumption_inventory_unit, foreign_key: 'lvc_inventory_unit_id'

	STATUS = { unfinished: '未完成', finished: '完成'}

	def status_name
		status.blank? ? "" : LowValueConsumptionInventoryUnit::STATUS["#{status}".to_sym]
	end
end
