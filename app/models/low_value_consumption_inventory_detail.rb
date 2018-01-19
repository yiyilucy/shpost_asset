class LowValueConsumptionInventoryDetail < ActiveRecord::Base
	self.table_name = "lvc_inventory_details"
	belongs_to :low_value_consumption_inventory, class_name: 'LowValueConsumptionInventory', foreign_key: "lvc_inventory_id"
	belongs_to :low_value_consumption_catalog, class_name: 'LowValueConsumptionCatalog', foreign_key: "lvc_catalog_id"
	belongs_to :unit
	belongs_to :low_value_consumption_inventory_unit, class_name: 'LowValueConsumptionInventoryUnit', foreign_key: "lvc_inventory_unit_id"
	belongs_to :relevant_unit, class_name: 'Unit'
	belongs_to :manage_unit, class_name: 'Unit'
	belongs_to :use_unit, class_name: 'Unit'
	belongs_to :low_value_consumption_info
	has_one :lvc_img, dependent: :destroy
	belongs_to :inventory_user, class_name: 'User'

	INVENTORY_STATUS = { waiting: '待扫描', match: '匹配', unmatch: '不匹配', no_scan: '未扫描'}

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
