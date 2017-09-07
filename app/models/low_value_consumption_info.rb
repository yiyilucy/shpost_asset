class LowValueConsumptionInfo < ActiveRecord::Base
	belongs_to :low_value_consumption_catalog

	STATUS = { waiting: '待复核', checking: '复核中', in_use: '在用', discard: '报废' }

	def status_name
		status.blank? ? "" : LowValueConsumptionInfo::STATUS["#{status}".to_sym]
	end
end
