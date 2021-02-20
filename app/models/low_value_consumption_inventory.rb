class LowValueConsumptionInventory < ActiveRecord::Base
	self.table_name = "lvc_inventories"
	has_many :low_value_consumption_inventory_units, dependent: :destroy, inverse_of: :low_value_consumption_inventory, foreign_key: 'lvc_inventory_id'
	has_many :low_value_consumption_inventory_details, dependent: :destroy, inverse_of: :low_value_consumption_inventory, foreign_key: 'lvc_inventory_id'
	belongs_to :create_user, class_name: 'User'
	belongs_to :create_unit, class_name: 'Unit'
	belongs_to :low_value_consumption_catalog, class_name: 'LowValueConsumptionCatalog', foreign_key: "lvc_catalog_id"
	belongs_to :sample_unit, class_name: 'Unit'


	STATUS = { waiting: '待处理', doing: '盘点中', canceled: '取消', done: '完成'}

	def status_name
		status.blank? ? "" : LowValueConsumptionInventory::STATUS["#{status}".to_sym]
	end

	def self.start_inventory
		LowValueConsumptionInventory.where(status: "waiting").each do |x|
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

  def self.done(inventory, inventory_details, inventory_units)
  	inventory_details.each do |x|
      if x.inventory_status.eql?"waiting"
        x.update inventory_status: "no_scan", end_date: Time.now
      end
    end

    inventory_units.each do |u|
      if u.status.eql?"unfinished"
        u.update status: "finished"
      end
    end

    inventory.update status: "done"
  end

  def self.inventory_amount(inventory_details, current_user, inventory_status)
  	amount = 0

  	if current_user.unit.unit_level == 2 
  		if inventory_status.nil?
      	amount = inventory_details.where(manage_unit_id: current_user.unit_id).size
      else
      	amount = inventory_details.where(manage_unit_id: current_user.unit_id, inventory_status: inventory_status).size
      end
    elsif current_user.unit.unit_level == 3
      child_ids = Unit.where(parent_id: current_user.unit_id).select(:id)

      if inventory_status.nil?
     		amount = inventory_details.where("(use_unit_id = ? or use_unit_id in (?))", current_user.unit_id, child_ids).size
     	else
     		amount = inventory_details.where("(use_unit_id = ? or use_unit_id in (?)) and inventory_status = ?", current_user.unit_id, child_ids, inventory_status).size
     	end
    end 
    return amount
  end

  def self.sub_done(inventory_units, inventory_details, current_user)
  	sub_unit = inventory_units.find_by(unit_id: current_user.unit_id)

    if !sub_unit.blank?
      inventory_details = inventory_details.where(manage_unit_id: current_user.unit_id)

      inventory_details.each do |x|
        if x.inventory_status.eql?"waiting"
          x.update inventory_status: "no_scan", end_date: Time.now
        end
      end

      sub_unit.update status: "finished"
    end
  end
end
