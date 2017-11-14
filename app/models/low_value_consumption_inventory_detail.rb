class LowValueConsumptionInventoryDetail < ActiveRecord::Base
	belongs_to :low_value_consumption_inventory
	belongs_to :low_value_consumption_catalog
	belongs_to :unit
	belongs_to :low_value_consumption_inventory_unit
	belongs_to :relevant_unit, class_name: 'Unit'
	belongs_to :manage_unit, class_name: 'Unit'
	belongs_to :use_unit, class_name: 'Unit'
	belongs_to :low_value_consumption_info

	INVENTORY_STATUS = { waiting: '待扫描', match: '匹配', unmatch: '不匹配'}

	def inventory_status_name
		inventory_status.blank? ? "" : LowValueConsumptionInventoryDetail::INVENTORY_STATUS["#{inventory_status}".to_sym]
	end

	def is_check_name
	  if is_check
	    name = "是"
	  else
	    name = "否"
	  end
	end
end
