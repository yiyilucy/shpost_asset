class RentInfo < ActiveRecord::Base
	belongs_to :fixed_asset_catalog
	belongs_to :purchase
	belongs_to :relevant_unit, class_name: 'Unit'
	belongs_to :manage_unit, class_name: 'Unit'
	belongs_to :use_unit, class_name: 'Unit'

	def status_name
		status.blank? ? "" : LowValueConsumptionInfo::STATUS["#{status}".to_sym]
	end

	def is_reprint_name
	  if is_reprint
	    name = "是"
	  else
	    name = "否"
	  end
	end
end
