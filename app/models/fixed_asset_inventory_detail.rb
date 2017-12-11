class FixedAssetInventoryDetail < ActiveRecord::Base
	belongs_to :fixed_asset_inventory
	belongs_to :fixed_asset_catalog
	belongs_to :unit
	belongs_to :fixed_asset_inventory_unit
	belongs_to :relevant_unit, class_name: 'Unit'
	belongs_to :manage_unit, class_name: 'Unit'
	belongs_to :fixed_asset_info
	has_one :fixed_asset_img, dependent: :destroy, inverse_of: :fixed_asset_inventory_detail, foreign_key: 'fa_inventory_detail_id'

	INVENTORY_STATUS = { waiting: '待扫描', match: '匹配', unmatch: '不匹配'}

	def inventory_status_name
		inventory_status.blank? ? "" : FixedAssetInventoryDetail::INVENTORY_STATUS["#{inventory_status}".to_sym]
	end

	def is_check_name
	  if is_check
	    name = "是"
	  else
	    name = "否"
	  end
	end
end
