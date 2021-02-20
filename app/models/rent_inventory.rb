class RentInventory < ActiveRecord::Base
	has_many :rent_inventory_units, dependent: :destroy, inverse_of: :rent_inventory, foreign_key: 'rent_inventory_id'
	has_many :rent_inventory_details, dependent: :destroy, inverse_of: :rent_inventory, foreign_key: 'rent_inventory_id'
	belongs_to :create_user, class_name: 'User'
	belongs_to :create_unit, class_name: 'Unit'
	belongs_to :fixed_asset_catalog, class_name: 'FixedAssetCatalog', foreign_key: "fixed_asset_catalog_id"
	belongs_to :sample_unit, class_name: 'Unit'


	STATUS = { waiting: '待处理', doing: '盘点中', canceled: '取消', done: '完成'}

	def status_name
		status.blank? ? "" : RentInventory::STATUS["#{status}".to_sym]
	end

	def self.start_inventory
		RentInventory.where(status: "waiting").each do |x|
			if DateTime.parse(x.start_time.to_s).strftime('%Y-%m-%d').to_s <= DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d').to_s
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
