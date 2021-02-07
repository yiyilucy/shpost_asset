class FixedAssetCatalog < ActiveRecord::Base
	has_many :fixed_asset_infos, dependent: :destroy
	has_many :purchase
	has_many :rent_infos, dependent: :destroy

	def self.get_catalog_name(fixed_asset_catalog_id)
		fixed_asset_catalog = FixedAssetCatalog.find_by(id: fixed_asset_catalog_id).try(:name)
	end

	def is_house?
		if !self.code.blank? && ((self.code.starts_with?"0101") || (self.code.starts_with?"0102"))
			return true
		else
			return false
		end
	end

	def is_car?
		if !self.code.blank? && ((self.code.starts_with?"040201") || (self.code.starts_with?"040202") || (self.code.starts_with?"040203") || (self.code.starts_with?"040204"))
			return true
		else
			return false
		end
	end
end
