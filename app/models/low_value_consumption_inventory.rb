class LowValueConsumptionInventory < ActiveRecord::Base
	has_many :low_value_consumption_inventory_units, dependent: :destroy, inverse_of: :low_value_consumption_inventory, foreign_key: 'lvc_inventory_id'
	has_many :low_value_consumption_inventory_details, dependent: :destroy, inverse_of: :low_value_consumption_inventory, foreign_key: 'lvc_inventory_id'
	belongs_to :create_user, class_name: 'User'
	belongs_to :create_unit, class_name: 'Unit'


	STATUS = { waiting: '待处理', doing: '盘点中', canceled: '取消', done: '完成'}

	def status_name
		status.blank? ? "" : LowValueConsumptionInventory::STATUS["#{status}".to_sym]
	end

	def self.start_inventory
		LowValueConsumptionInventory.where(status: "waiting").each do |x|
			if DateTime.parse(x.start_time.to_s).strftime('%Y-%m-%d').to_s == DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d').to_s
				x.update status: "doing"
			end
		end
	end

	def is_lv2_unit_name
     if is_lv2_unit
        name = "是"
     else
        name = "否"
     end
   end
end
