class LvcImg < ActiveRecord::Base
	belongs_to :low_value_consumption_inventory_detail
	belongs_to :low_value_consumption_info
	
	
end