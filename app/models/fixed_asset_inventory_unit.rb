class FixedAssetInventoryUnit < ActiveRecord::Base
	belongs_to :fixed_asset_inventory
	has_many :fixed_asset_inventory_details

	STATUS = { unfinished: '未完成', finished: '完成'}

	def status_name
		status.blank? ? "" : FixedAssetInventoryUnit::STATUS["#{status}".to_sym]
	end
end
