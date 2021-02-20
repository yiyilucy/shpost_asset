class RentInventoryUnit < ActiveRecord::Base
	belongs_to :rent_inventory, class_name: 'RentInventory', foreign_key: "rent_inventory_id"
	
	has_many :rent_inventory_details, inverse_of: :rent_inventory_unit, foreign_key: 'rent_inventory_unit_id'

	STATUS = { unfinished: '未完成', finished: '完成'}

	def status_name
		status.blank? ? "" : RentInventoryUnit::STATUS["#{status}".to_sym]
	end
end
