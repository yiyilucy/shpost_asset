class LowValueConsumptionCatalog < ActiveRecord::Base
	has_many :low_value_consumption_infos, dependent: :destroy, inverse_of: :low_value_consumption_catalog, foreign_key: 'lvc_catalog_id'
	has_many :purchase
	has_many :low_value_consumption_inventory_details, inverse_of: :low_value_consumption_catalog, foreign_key: 'lvc_catalog_id'

	def self.get_catalog_name(lvc_catalog_id)
		low_value_consumption_catalog = LowValueConsumptionCatalog.find_by(id: lvc_catalog_id).try(:name)
	end
end
