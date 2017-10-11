class LowValueConsumptionCatalog < ActiveRecord::Base
	has_many :low_value_consumption_infos, dependent: :destroy
	has_many :purchase
end
