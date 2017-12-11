class FixedAssetImg < ActiveRecord::Base
	belongs_to :fixed_asset_inventory_detail, class_name: 'FixedAssetInventoryDetail', foreign_key: "fa_inventory_detail_id"
	belongs_to :fixed_asset_info
	
	
end