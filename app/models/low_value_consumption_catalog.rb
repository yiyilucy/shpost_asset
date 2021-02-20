class LowValueConsumptionCatalog < ActiveRecord::Base
	has_many :low_value_consumption_infos, dependent: :destroy, inverse_of: :low_value_consumption_catalog, foreign_key: 'lvc_catalog_id'
	has_many :purchase
	has_many :low_value_consumption_inventory_details, inverse_of: :low_value_consumption_catalog, foreign_key: 'lvc_catalog_id'

	def self.get_catalog_name(lvc_catalog_id)
		low_value_consumption_catalog = LowValueConsumptionCatalog.find_by(id: lvc_catalog_id).try(:name)
	end

	def self.get_full_catalog_name(lvc_catalog_id)
		code = LowValueConsumptionCatalog.find(lvc_catalog_id).code
        code1 = LowValueConsumptionCatalog.find_by(code: code[0,2]).try :name
        if code.length>=4
            code2 = LowValueConsumptionCatalog.find_by(code: code[0,4]).try :name
        else
            code2 = ""
        end
        if code.length>=6
            code3 = LowValueConsumptionCatalog.find_by(code: code[0,6]).try :name
        else
            code3 = ""
        end
        if code.length>=8
            code4 = LowValueConsumptionCatalog.find_by(code: code[0,8]).try :name
        else
            code4 = ""
        end
        print_code = (code1.blank? ? "" : code1)+"."+(code2.blank? ? "" : code2)+"."+(code3.blank? ? "" : code3)+"."+(code4.blank? ? "" : code4)
    end
end
