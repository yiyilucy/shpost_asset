class LowValueConsumptionInfo < ActiveRecord::Base
	belongs_to :low_value_consumption_catalog, class_name: 'LowValueConsumptionCatalog', foreign_key: "lvc_catalog_id"
	belongs_to :purchase
	belongs_to :relevant_unit, class_name: 'Unit'
	belongs_to :manage_unit, class_name: 'Unit'
	belongs_to :use_unit, class_name: 'Unit'
	has_many :low_value_consumption_inventory_details
	has_many :lvc_imgs
	has_one :lvc_discard_detail
	# validates_uniqueness_of :asset_no, :message => '该资产编号已存在'
	
	STATUS = { waiting: '待处理', checking: '待复核', declined: '否决', canceled: '取消', in_use: '在用', revoked: '撤回', discard: '报废' }
	
	def status_name
		status.blank? ? "" : LowValueConsumptionInfo::STATUS["#{status}".to_sym]
	end

	def is_rent_name
	  if is_rent
	    name = "是"
	  else
	    name = "否"
	  end
	end

	def self.select_years
	  years = [""]
	  i=2018

	  current_year = Time.now.year
	  while i<=(current_year+5)
	  	years << i
	  	i +=1
	  end
	  
	  return years
	end

	def self.select_months
	  ["","1","2","3","4","5","6","7","8","9","10","11","12"]
	end

	def is_reprint_name
	  if is_reprint
	    name = "是"
	  else
	    name = "否"
	  end
	end

	def self.get_in_use_infos(object, user, catalog4, catalog3, catalog2, catalog1)
		infos = nil

		if user.unit.blank?
      infos = object.where(status: "in_use")
    else
      if user.unit.unit_level == 1
        infos = object.where(status: "in_use")
      elsif user.unit.is_facility_management_unit
        infos = object.where("(relevant_unit_id = ? or use_unit_id = ?) and status = ?", user.unit_id, user.unit_id, "in_use")
      elsif user.unit.unit_level == 2
        infos = object.where(manage_unit_id: user.unit_id, status: "in_use")
      elsif user.unit.unit_level == 3 && !user.unit.is_facility_management_unit 
        infos = object.where("(use_unit_id = ? or use_unit_id in (?)) and status = ?", user.unit_id, user.unit.children.map{|x| x.id}, "in_use")
      end
    end
    
    if object.eql? LowValueConsumptionInfo
	    if !catalog4.blank?
	      infos = infos.where(lvc_catalog_id: catalog4.to_i)
	    elsif !catalog3.blank?
	      catalog3_code = LowValueConsumptionCatalog.find(catalog3.to_i).code
	      infos = infos.joins(:low_value_consumption_catalog).where("low_value_consumption_catalogs.code like ?", "#{catalog3_code}%" )  
	    elsif !catalog2.blank?
	      catalog2_code = LowValueConsumptionCatalog.find(catalog2.to_i).code
	      infos = infos.joins(:low_value_consumption_catalog).where("low_value_consumption_catalogs.code like ?", "#{catalog2_code}%" )  
	    elsif !catalog1.blank?
	      catalog1_code = LowValueConsumptionCatalog.find(catalog1.to_i).code
	      infos = infos.joins(:low_value_consumption_catalog).where("low_value_consumption_catalogs.code like ?", "#{catalog1_code}%" )  
	    end
	  elsif object.eql? RentInfo
	  	if !catalog4.blank?
	      infos = infos.where(fixed_asset_catalog_id: catalog4.to_i)
	    elsif !catalog3.blank?
	      catalog3_code = FixedAssetCatalog.find(catalog3.to_i).code
	      infos = infos.joins(:fixed_asset_catalog).where("fixed_asset_catalogs.code like ?", "#{catalog3_code}%" )  
	    elsif !catalog2.blank?
	      catalog2_code = FixedAssetCatalog.find(catalog2.to_i).code
	      infos = infos.joins(:fixed_asset_catalog).where("fixed_asset_catalogs.code like ?", "#{catalog2_code}%" )  
	    elsif !catalog1.blank?
	      catalog1_code = FixedAssetCatalog.find(catalog1.to_i).code
	      infos = infos.joins(:low_value_consumption_catalog).where("fixed_asset_catalogs.code like ?", "#{catalog1_code}%" )  
	    end
	  end
	  return infos
	end

	def self.select_catalog2(object, catalog1)
		catalog2s = nil

    if !catalog1.blank?
      code = object.find(catalog1.to_i).code
      catalog2s = object.where("length(code)=4 and code like ?", "#{code}%").order(:code).map{|c| [c.name,c.id]}.insert(0,"")
    end

    return catalog2s
  end

  def self.select_catalog3(object, catalog2)
		catalog3s = nil

    if !catalog2.blank?
      code = object.find(catalog2.to_i).code
      catalog3s = object.where("length(code)=6 and code like ?", "#{code}%").order(:code).map{|c| [c.name,c.id]}.insert(0,"")
    end

    return catalog3s
  end

  def self.select_catalog4(object, catalog3)
		catalog4s = nil

    if !catalog3.blank?
      code = object.find(catalog3.to_i).code
      catalog4s = object.where("length(code)=8 and code like ?", "#{code}%").order(:code).map{|c| [c.name,c.id]}.insert(0,"")
    end

    return catalog4s
  end



end
