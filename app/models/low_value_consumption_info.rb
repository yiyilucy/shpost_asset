class LowValueConsumptionInfo < ActiveRecord::Base
	belongs_to :low_value_consumption_catalog, class_name: 'LowValueConsumptionCatalog', foreign_key: "lvc_catalog_id"
	belongs_to :purchase
	belongs_to :relevant_unit, class_name: 'Unit'
	belongs_to :manage_unit, class_name: 'Unit'
	belongs_to :use_unit, class_name: 'Unit'
	has_many :low_value_consumption_inventory_details
	has_many :lvc_imgs
	has_one :lvc_discard_detail
	# validates_uniqueness_of :asset_no, :message => '该资产编号已存在'
	
	STATUS = { waiting: '待处理', checking: '待复核', declined: '否决', canceled: '取消', in_use: '在用', revoked: '撤回', discard: '报废' }

	def status_name
		status.blank? ? "" : LowValueConsumptionInfo::STATUS["#{status}".to_sym]
	end


end
