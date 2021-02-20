class RentInventoryDetail < ActiveRecord::Base
	belongs_to :rent_inventory, class_name: 'RentInventory', foreign_key: "rent_inventory_id"
	belongs_to :fixed_asset_catalog, class_name: 'FixedAssetCatalog', foreign_key: "fixed_asset_catalog_id"
	belongs_to :unit
	belongs_to :rent_inventory_unit, class_name: 'RentInventoryUnit', foreign_key: "rent_inventory_unit_id"
	belongs_to :relevant_unit, class_name: 'Unit'
	belongs_to :manage_unit, class_name: 'Unit'
	belongs_to :use_unit, class_name: 'Unit'
	belongs_to :rent_info
	has_one :rent_img, dependent: :destroy
	belongs_to :inventory_user, class_name: 'User'

	INVENTORY_STATUS = { waiting: '待扫描', match: '匹配', unmatch: '不匹配', no_scan: '未扫描'}

	def inventory_status_name
		inventory_status.blank? ? "" : RentInventoryDetail::INVENTORY_STATUS["#{inventory_status}".to_sym]
	end

	def is_check_name
	  if is_check
	    name = "是"
	  else
	    name = "否"
	  end
	end
end
