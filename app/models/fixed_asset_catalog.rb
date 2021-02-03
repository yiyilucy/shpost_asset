class FixedAssetCatalog < ActiveRecord::Base
	has_many :fixed_asset_infos, dependent: :destroy
	has_many :purchase
	has_many :rent_infos, dependent: :destroy
end
