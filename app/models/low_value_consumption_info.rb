class LowValueConsumptionInfo < ActiveRecord::Base
	belongs_to :low_value_consumption_catalog
	belongs_to :purchase

	STATUS = { waiting: '待处理', checking: '待复核', declined: '否决', canceled: '取消', in_use: '在用', revoked: '撤回', discard: '报废' }

	def status_name
		status.blank? ? "" : LowValueConsumptionInfo::STATUS["#{status}".to_sym]
	end
end
