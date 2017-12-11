class FixedAssetInfo < ActiveRecord::Base
	belongs_to :fixed_asset_catalog
	belongs_to :unit
	has_many :fixed_asset_inventory_details
	has_many :fixed_asset_imgs


	STATUS = { in_use: '在用', discard: '报废' }

	def status_name
		status.blank? ? "" : FixedAssetInfo::STATUS["#{status}".to_sym]
	end
end
