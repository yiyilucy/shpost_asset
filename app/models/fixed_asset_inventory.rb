class FixedAssetInventory < ActiveRecord::Base
	has_many :fixed_asset_inventory_units, dependent: :destroy
	has_many :fixed_asset_inventory_details, dependent: :destroy
	belongs_to :create_user, class_name: 'User'
	belongs_to :create_unit, class_name: 'Unit'


	STATUS = { waiting: '待处理', doing: '盘点中', canceled: '取消', done: '完成'}

	def status_name
		status.blank? ? "" : FixedAssetInventory::STATUS["#{status}".to_sym]
	end

	def self.start_inventory
		FixedAssetInventory.where(status: "waiting").each do |x|
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
