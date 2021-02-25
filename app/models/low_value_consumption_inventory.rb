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

  def self.process_params(params)
    end_date = DateTime
    unit_ids = []
    relevant_unit_ids = []
    unit_names = []
    relevant_unit_names = []
    return_datas = Hash.new

    # 查询页面过来
    if !params[:end_date].blank? && !params[:end_date]["end_date"].blank?
      end_date = to_date(params[:end_date]["end_date"])+1
    # 报表页面过来
    elsif !params[:edate].blank?
      end_date = to_date(params[:edate])+1
    else
      end_date = Time.now
    end
    return_datas["end_date"] = end_date
    return_datas["edate"] = (end_date-1).strftime("%Y-%m-%d")
    
    if !params[:checkbox_unit].blank?
      params[:checkbox_unit].each do |x|     
        if x[1].eql?"1"   
          unit_ids << x[0].to_i 
          unit_names << Unit.find(x[0].to_i).name
        end
      end
    elsif !params[:uids].blank?
        unit_ids = eval(params[:uids])
        unit_ids.each do |x|
          unit_names << Unit.find(x).name
        end
    end
    return_datas["unit_ids"] = unit_ids
    return_datas["unit_names"] = unit_names.compact.join(",")

    if !params[:checkbox_relevant].blank?
      params[:checkbox_relevant].each do |x|     
        if x[1].eql?"1"   
          relevant_unit_ids << x[0].to_i 
          relevant_unit_names << Unit.find(x[0].to_i).name
        end
      end
    elsif !params[:rids].blank?
      relevant_unit_ids = eval(params[:rids])
      relevant_unit_ids.each do |x|
        relevant_unit_names << Unit.find(x).name
      end  
    end
    return_datas["relevant_unit_ids"] = relevant_unit_ids
    return_datas["relevant_unit_names"] = relevant_unit_names.compact.join(",")

    return  return_datas   
  end

  def self.get_results(object, current_user, params, return_datas)
    sum_amount = Hash.new
    status_amount = Hash.new
    results = Hash.new
    total_amount = 0
    match_amount = 0
    unmatch_amount = 0
    no_scan_amount = 0
    waiting_amount = 0

    if (current_user.unit.unit_level == 1) || (current_user.unit.is_facility_management_unit)
      if object.eql? LowValueConsumptionInventoryDetail
        sum_amount = object.where("lvc_inventory_id = ? and manage_unit_id in (?) and relevant_unit_id in (?)", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"]).group(:manage_unit_id).order(:manage_unit_id).count
        status_amount = object.where("lvc_inventory_id = ? and manage_unit_id in (?) and relevant_unit_id in (?) and end_date <= ?", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"], return_datas["end_date"]).group(:manage_unit_id).group(:inventory_status).order(:manage_unit_id, :inventory_status).count
      elsif object.eql? RentInventoryDetail
        sum_amount = object.where("rent_inventory_id = ? and manage_unit_id in (?) and relevant_unit_id in (?)", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"]).group(:manage_unit_id).order(:manage_unit_id).count
        status_amount = object.where("rent_inventory_id = ? and manage_unit_id in (?) and relevant_unit_id in (?) and end_date <= ?", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"], return_datas["end_date"]).group(:manage_unit_id).group(:inventory_status).order(:manage_unit_id, :inventory_status).count
      end
    else 
      if object.eql? LowValueConsumptionInventoryDetail
        sum_amount = object.where("lvc_inventory_id = ? and use_unit_id in (?) and relevant_unit_id in (?)", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"]).group(:use_unit_id).order(:use_unit_id).count
        status_amount = object.where("lvc_inventory_id = ? and use_unit_id in (?) and relevant_unit_id in (?) and end_date <= ?", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"], return_datas["end_date"]).group(:use_unit_id).group(:inventory_status).order(:use_unit_id, :inventory_status).count
      elsif object.eql? RentInventoryDetail
        sum_amount = object.where("rent_inventory_id = ? and use_unit_id in (?) and relevant_unit_id in (?)", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"]).group(:use_unit_id).order(:use_unit_id).count
        status_amount = object.where("rent_inventory_id = ? and use_unit_id in (?) and relevant_unit_id in (?) and end_date <= ?", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"], return_datas["end_date"]).group(:use_unit_id).group(:inventory_status).order(:use_unit_id, :inventory_status).count
      end
    end
      
    sum_amount.each do |k,v|
      match_am = status_amount[[k, "match"]].blank? ? 0 : status_amount[[k, "match"]]
      match_amount += match_am
      unmatch_am = status_amount[[k, "unmatch"]].blank? ? 0 : status_amount[[k, "unmatch"]]
      unmatch_amount += unmatch_am
      no_scan_am = status_amount[[k, "no_scan"]].blank? ? 0 : status_amount[[k, "no_scan"]]
      no_scan_amount += no_scan_am
      waiting_am = v-match_am-unmatch_am-no_scan_am
      waiting_amount += waiting_am
      total_amount += v

      results[k]=[v, match_am, unmatch_am, no_scan_am, waiting_am]
      return_datas["total_amount"] = total_amount
      return_datas["match_amount"] = match_amount
      return_datas["unmatch_amount"] = unmatch_amount
      return_datas["no_scan_amount"] = no_scan_amount
      return_datas["waiting_amount"] = waiting_amount
    end

    return results
  end

  def self.to_date(time)
    date = Date.civil(time.split(/-|\//)[0].to_i,time.split(/-|\//)[1].to_i,time.split(/-|\//)[2].to_i)
    return date
  end

  def self.get_sample_infos(object, start_sum, end_sum, catalog_id, pd_unit, current_user)
    infos = nil

    if object.eql? LowValueConsumptionInventory
      infos = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where("low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ? ", "in_use", start_sum)

      if !end_sum.blank?
        infos = infos.where("low_value_consumption_infos.sum <= ?", end_sum)
      end

      if !catalog_id.blank?
        code = LowValueConsumptionCatalog.find(catalog_id).code
        infos = infos.where("low_value_consumption_catalogs.code like ?", "#{code}%")
      end
    elsif object.eql? RentInventory
      infos = RentInfo.joins(:fixed_asset_catalog).where("rent_infos.status = ?", "in_use")

      if !catalog_id.blank?
        code = FixedAssetCatalog.find(catalog_id).code
        infos = infos.where("fixed_asset_catalogs.code like ?", "#{code}%")
      end
    end

    if !pd_unit.blank?
      if pd_unit.unit_level == 2
        infos = infos.where("(use_unit_id = ? or manage_unit_id = ?)", pd_unit.id, pd_unit.id)
      elsif pd_unit.unit_level == 3
        lv4_unit_ids = Unit.where(parent_id: pd_unit.id).select(:id)
        infos = infos.where("(use_unit_id = ? or use_unit_id in (?))", pd_unit.id, lv4_unit_ids)
      end
    end

    if current_user.unit.unit_level == 3 && current_user.unit.is_facility_management_unit
      infos = infos.where("relevant_unit_id = ?", current_user.unit.id)
    end

    return infos
  end

end
