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

	def self.get_full_catalog_name(fixed_asset_catalog_id)
		code = FixedAssetCatalog.find(fixed_asset_catalog_id).code
        code1 = FixedAssetCatalog.find_by(code: code[0,2]).try :name
        if code.length>=4
            code2 = FixedAssetCatalog.find_by(code: code[0,4]).try :name
        else
            code2 = ""
        end
        if code.length>=6
            code3 = FixedAssetCatalog.find_by(code: code[0,6]).try :name
        else
            code3 = ""
        end
        if code.length>=8
            code4 = FixedAssetCatalog.find_by(code: code[0,8]).try :name
        else
            code4 = ""
        end
        print_code = (code1.blank? ? "" : code1)+"."+(code2.blank? ? "" : code2)+"."+(code3.blank? ? "" : code3)+"."+(code4.blank? ? "" : code4)
	end
end
