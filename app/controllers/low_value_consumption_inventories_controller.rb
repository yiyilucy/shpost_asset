class LowValueConsumptionInventoriesController < ApplicationController
  load_and_authorize_resource

  def index
    @low_value_consumption_inventories = LowValueConsumptionInventory.where(create_user_id: current_user.id, is_sample: false)
    @low_value_consumption_inventories_grid = initialize_grid(@low_value_consumption_inventories, order: 'lvc_inventories.created_at',
      order_direction: 'desc')
  end

  def level2_index
    @low_value_consumption_inventories = LowValueConsumptionInventory.where(is_lv2_unit: true, is_sample: false)
    @low_value_consumption_inventories_grid = initialize_grid(@low_value_consumption_inventories, order: 'lvc_inventories.created_at',
      order_direction: 'desc')
  end

  def doing_index
    lv3_unit_ids = current_user.unit.children.select(:id)
    
    if current_user.unit.unit_level == 2
      @low_value_consumption_inventories = LowValueConsumptionInventory.includes(:low_value_consumption_inventory_units).where("lvc_inventories.status in (?) and (lvc_inventory_units.unit_id = ? or lvc_inventory_units.unit_id in (?)) and lvc_inventories.create_unit_id != ? and lvc_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit_id, lv3_unit_ids, current_user.unit_id, false)
    elsif current_user.unit.unit_level == 3
      @low_value_consumption_inventories = LowValueConsumptionInventory.includes(:low_value_consumption_inventory_units).where("lvc_inventories.status in (?) and (lvc_inventory_units.unit_id = ? or lvc_inventory_units.unit_id = ?) and lvc_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit.parent_id, current_user.unit.id, false)
    elsif current_user.unit.unit_level == 4
      @low_value_consumption_inventories = LowValueConsumptionInventory.includes(:low_value_consumption_inventory_units).where("lvc_inventories.status in (?) and (lvc_inventory_units.unit_id = ? or lvc_inventory_units.unit_id = ? or lvc_inventory_units.unit_id = ?) and lvc_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit.parent_id, current_user.unit.id, current_user.unit.parent.parent_id, false)  
    end
        
    
    @low_value_consumption_inventories_grid = initialize_grid(@low_value_consumption_inventories, order: 'lvc_inventories.created_at',
      order_direction: 'desc')
  end

  def sample_inventory_index
    @low_value_consumption_inventories = LowValueConsumptionInventory.where(create_user_id: current_user.id, is_sample: true)
    @low_value_consumption_inventories_grid = initialize_grid(@low_value_consumption_inventories, order: 'lvc_inventories.created_at',
      order_direction: 'desc')
  end

  def sample_inventory_doing_index
    lv3_unit_ids = current_user.unit.children.select(:id)

    if current_user.unit.unit_level == 2
      @low_value_consumption_inventories = LowValueConsumptionInventory.includes(:low_value_consumption_inventory_units).where("lvc_inventories.status in (?) and lvc_inventory_units.unit_id in (?) and lvc_inventories.create_unit_id != ? and lvc_inventories.is_sample = ?", ["doing", "canceled", "done"], lv3_unit_ids, current_user.unit_id, true)
    elsif current_user.unit.unit_level == 3
      @low_value_consumption_inventories = LowValueConsumptionInventory.includes(:low_value_consumption_inventory_units).where("lvc_inventories.status in (?) and lvc_inventory_units.unit_id = ? and lvc_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit.id, true)
    elsif current_user.unit.unit_level == 4
      @low_value_consumption_inventories = LowValueConsumptionInventory.includes(:low_value_consumption_inventory_units).where("lvc_inventories.status in (?) and lvc_inventory_units.unit_id = ? and lvc_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit.parent_id, true)  
    end
        
    
    @low_value_consumption_inventories_grid = initialize_grid(@low_value_consumption_inventories, order: 'lvc_inventories.created_at',
      order_direction: 'desc')
  end

  def show
  end

  def new
    @inventory = LowValueConsumptionInventory.new
    if current_user.unit.unit_level == 1
      @units_grid = initialize_grid(Unit.where(unit_level: 2).order(:no), per_page: 1000,:name => 'g1')
      @relevant_departments_grid = initialize_grid(Unit.where(is_facility_management_unit: true).order(:no), per_page: 1000,:name => 'g2')
    elsif current_user.unit.is_facility_management_unit
      @units_grid = initialize_grid(Unit.where(unit_level: 2).order(:no), per_page: 1000,:name => 'g1')
      @relevant_departments_grid = initialize_grid(Unit.where(id: current_user.unit_id), per_page: 1000,:name => 'g2')
    elsif current_user.unit.unit_level == 2
      lv3units = Unit.where(parent_id: current_user.unit_id).select(:id)
      @units_grid = initialize_grid(Unit.where("parent_id = ? or id = ? or parent_id in (?)", current_user.unit_id, current_user.unit_id, lv3units).order(:unit_level, :no), per_page: 1000,:name => 'g1')
      @relevant_departments_grid = initialize_grid(Unit.where(is_facility_management_unit: true).order(:no), per_page: 1000,:name => 'g2')
    end
  end

  def edit
  end

  def create
    @start_sum = 0
    @end_sum = nil

    ActiveRecord::Base.transaction do
      if !params[:g1].nil?
        units = params[:g1][:selected]
      end
      if !params[:g2].nil?
        relevant_departments = params[:g2][:selected]
      end
      if units.blank?
        flash[:alert] = "请先选择盘点单位"
        redirect_to low_value_consumption_inventories_url and return
      end
      if relevant_departments.blank?
        flash[:alert] = "请先选择资产归口单位"
        redirect_to low_value_consumption_inventories_url and return
      end

      if !params[:start_sum].blank? and !params[:start_sum]["start_sum"].blank?
        @start_sum = params[:start_sum]["start_sum"].to_i
      end

      if !params[:end_sum].blank? and !params[:end_sum]["end_sum"].blank?
        @end_sum = params[:end_sum]["end_sum"].to_i
      end

      
# binding.pry
      if current_user.unit.unit_level == 2
        if @end_sum.blank?
          low_value_consumption_infos = LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and low_value_consumption_infos.use_unit_id in (?) and low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ? ", relevant_departments, units, "in_use", @start_sum)
        else
          low_value_consumption_infos = LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and low_value_consumption_infos.use_unit_id in (?) and low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ? and low_value_consumption_infos.sum <= ?", relevant_departments, units, "in_use", @start_sum, @end_sum)
        end
      else
        if @end_sum.blank?
          low_value_consumption_infos = LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and (low_value_consumption_infos.use_unit_id in (?) or low_value_consumption_infos.manage_unit_id in (?)) and low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ?", relevant_departments, units, units, "in_use", @start_sum)
        else
          low_value_consumption_infos = LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and (low_value_consumption_infos.use_unit_id in (?) or low_value_consumption_infos.manage_unit_id in (?)) and low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ? and low_value_consumption_infos.sum <= ?", relevant_departments, units, units, "in_use", @start_sum, @end_sum)
        end
      end

      if low_value_consumption_infos.blank?
        flash[:alert] = "没有符合条件的低值易耗品"
        redirect_to low_value_consumption_inventories_url and return
      end

      if !params[:low_value_consumption_inventory].blank?
        if params[:low_value_consumption_inventory][:start_time].blank? or params[:low_value_consumption_inventory][:end_time].blank?
          flash[:alert] = "请选择盘点开始时间和结束时间"
          redirect_to low_value_consumption_inventories_url and return
        end

        # if LowValueConsumptionInventory.includes(:low_value_consumption_inventory_units).where("lvc_inventory_units.unit_id in (?) and lvc_inventories.start_time <= ? and lvc_inventories.status in (?) and lvc_inventories.relevant_unit_ids like ?", units, DateTime.parse(params[:low_value_consumption_inventory][:start_time]), ["waiting", "doing"], "%#{relevant_departments.compact.join(",")}%").exists?
      
        #   flash[:alert] = "同一时间同一单位不可重叠盘点"
        #   redirect_to low_value_consumption_inventories_url and return
        # end
        
        @low_value_consumption_inventory.no = params[:low_value_consumption_inventory][:no]
        @low_value_consumption_inventory.name = params[:low_value_consumption_inventory][:name]
        @low_value_consumption_inventory.start_time = params[:low_value_consumption_inventory][:start_time]
        @low_value_consumption_inventory.end_time = params[:low_value_consumption_inventory][:end_time]
        @low_value_consumption_inventory.desc = params[:low_value_consumption_inventory][:desc]
        @low_value_consumption_inventory.status = "waiting"
        @low_value_consumption_inventory.create_user_id = current_user.id
        @low_value_consumption_inventory.create_unit_id = current_user.unit_id
        @low_value_consumption_inventory.relevant_unit_ids = relevant_departments.compact.join(",")

        if current_user.unit.unit_level == 2
          @low_value_consumption_inventory.is_lv2_unit = true
        end

        @low_value_consumption_inventory.save

        Unit.where(id: units).each do |x|
          if @low_value_consumption_inventory.is_lv2_unit
            if @end_sum.blank?
              if !LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and low_value_consumption_infos.use_unit_id = ? and low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ?", relevant_departments, x.id, "in_use", @start_sum).blank?
                @low_value_consumption_inventory.low_value_consumption_inventory_units.create(unit_id: x.id, status: "unfinished")
              end
            else
              if !LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and low_value_consumption_infos.use_unit_id = ? and low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ? and low_value_consumption_infos.sum <= ?", relevant_departments, x.id, "in_use", @start_sum, @end_sum).blank?
                @low_value_consumption_inventory.low_value_consumption_inventory_units.create(unit_id: x.id, status: "unfinished")
              end
            end
          else
            if @end_sum.blank?
              if !LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and (low_value_consumption_infos.use_unit_id = ? or low_value_consumption_infos.manage_unit_id = ?) and low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ?", relevant_departments, x.id, x.id, "in_use", @start_sum).blank?
                @low_value_consumption_inventory.low_value_consumption_inventory_units.create(unit_id: x.id, status: "unfinished")
              end
            else
              if !LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and (low_value_consumption_infos.use_unit_id = ? or low_value_consumption_infos.manage_unit_id = ?) and low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ? and low_value_consumption_infos.sum <= ?", relevant_departments, x.id, x.id, "in_use", @start_sum, @end_sum).blank?
                @low_value_consumption_inventory.low_value_consumption_inventory_units.create(unit_id: x.id, status: "unfinished")
              end
            end
          end
        end
          
        low_value_consumption_infos.each do |x|
          if @low_value_consumption_inventory.is_lv2_unit
            inventory_unit_id = LowValueConsumptionInventoryUnit.find_by(lvc_inventory_id: @low_value_consumption_inventory.id, unit_id: x.use_unit_id).blank? ? nil : LowValueConsumptionInventoryUnit.find_by(lvc_inventory_id: @low_value_consumption_inventory.id, unit_id: x.use_unit_id).id
          else
            inventory_unit_id = LowValueConsumptionInventoryUnit.find_by(lvc_inventory_id: @low_value_consumption_inventory.id, unit_id: x.manage_unit_id).blank? ? nil : LowValueConsumptionInventoryUnit.find_by(lvc_inventory_id: @low_value_consumption_inventory.id, unit_id: x.manage_unit_id).id
          end

          @low_value_consumption_inventory.low_value_consumption_inventory_details.create(sn: x.sn, asset_name: x.asset_name, asset_no: x.asset_no, lvc_catalog_id: x.lvc_catalog_id, relevant_unit_id: x.relevant_unit_id, buy_at: x.buy_at, use_at: x.use_at, measurement_unit: x.measurement_unit, sum: x.sum, use_unit_id: x.use_unit_id, branch: x.branch, location: x.location, user: x.user, change_log: x.change_log, consumption_status: x.status, print_times: x.print_times, brand_model: x.brand_model, batch_no: x.batch_no, purchase_id: x.purchase_id, manage_unit_id: x.manage_unit_id, inventory_status: "waiting", lvc_inventory_unit_id: inventory_unit_id, low_value_consumption_info_id: x.id, brand_model: x.brand_model, use_years: x.use_years, desc1: x.desc1)
        end

        
      end

      respond_to do |format|
        format.html { redirect_to low_value_consumption_inventories_url }
        format.json { head :no_content }
      end
    end
  end

  def update
    @low_value_consumption_inventory.update(low_value_consumption_inventory_params)
    respond_with(@low_value_consumption_inventory)
  end

  def destroy
    @low_value_consumption_inventory.destroy
    respond_with(@low_value_consumption_inventory)
  end

  def cancel
    @low_value_consumption_inventory.update status: "canceled"

    redirect_to request.referer
  end

  def done
    # all_finished = true

    # if current_user.unit.unit_level == 2 
    #   @low_value_consumption_inventory.low_value_consumption_inventory_details.each do |x|
    #     if x.inventory_status.eql?"waiting"
    #       x.update inventory_status: "no_scan", end_date: Time.now
    #     end
    #   end
    # elsif current_user.unit.is_facility_management_unit or current_user.unit.unit_level == 1
    #   @low_value_consumption_inventory.low_value_consumption_inventory_units.each do |x|
    #     if x.status.eql?"unfinished"
    #       all_finished = false
    #     end
    #   end
    # end

    # if all_finished
    #   @low_value_consumption_inventory.update status: "done"
    # else
    #   flash[:alert] = "请等待所有参与单位都完成后再点击"
    # end

    @low_value_consumption_inventory.low_value_consumption_inventory_details.each do |x|
      if x.inventory_status.eql?"waiting"
        x.update inventory_status: "no_scan", end_date: Time.now
      end
    end

    @low_value_consumption_inventory.low_value_consumption_inventory_units.each do |u|
      if u.status.eql?"unfinished"
        u.update status: "finished"
      end
    end

    @low_value_consumption_inventory.update status: "done"
  
    redirect_to request.referer
  end

  def sub_done
    sub_unit = @low_value_consumption_inventory.low_value_consumption_inventory_units.find_by(unit_id: current_user.unit_id)

    if !sub_unit.blank?
      # all_scanned = true
      low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.where(manage_unit_id: current_user.unit_id)

      low_value_consumption_inventory_details.each do |x|
        if x.inventory_status.eql?"waiting"
          # all_scanned = false
          x.update inventory_status: "no_scan", end_date: Time.now
        end
      end

      # if all_scanned
        sub_unit.update status: "finished"
      # else
      #   flash[:alert] = "低值易耗品盘点未全部完成"
      # end
    end

    respond_to do |format|
      format.html { redirect_to doing_index_low_value_consumption_inventories_url }
      format.json { head :no_content }
    end
  end

  def to_sample_inventory
    @inventory = LowValueConsumptionInventory.new
  end

  def sample_inventory
    @start_sum = 0
    @end_sum = nil
    lvc_catalog_id = nil
    lv3_unit_id = nil
    low_value_consumption_infos = nil
    inventory_unit_id = nil

    ActiveRecord::Base.transaction do
      if !params[:lvc_info].blank?
        if !params[:lvc_info][:lvc_catalog_id].blank?
          lvc_catalog_id = params[:lvc_info][:lvc_catalog_id].to_i
        else
          flash[:alert] = "请先选择资产类别目录"
          redirect_to to_sample_inventory_low_value_consumption_inventories_url and return
        end
        if !params[:lvc_info][:lv3_unit_id].blank?
          lv3_unit_id = params[:lvc_info][:lv3_unit_id].to_i
        else
          flash[:alert] = "请先选择三级单位"
          redirect_to to_sample_inventory_low_value_consumption_inventories_url and return
        end
      end

      if params[:low_value_consumption_inventory].blank? or params[:low_value_consumption_inventory][:start_time].blank? or params[:low_value_consumption_inventory][:end_time].blank?
        flash[:alert] = "请选择盘点开始时间和结束时间"
        redirect_to to_sample_inventory_low_value_consumption_inventories_url and return
      end

      if !params[:start_sum].blank? and !params[:start_sum]["start_sum"].blank?
        @start_sum = params[:start_sum]["start_sum"].to_i
      end

      if !params[:end_sum].blank? and !params[:end_sum]["end_sum"].blank?
        @end_sum = params[:end_sum]["end_sum"].to_i
      end

      lv4_unit_ids = Unit.where(parent_id: lv3_unit_id).select(:id)

      query_string = "low_value_consumption_infos.lvc_catalog_id = ? and (low_value_consumption_infos.use_unit_id =? or low_value_consumption_infos.use_unit_id in (?)) and low_value_consumption_infos.status = ? and low_value_consumption_infos.sum >= ? "
   
      if @end_sum.blank?
        if current_user.unit.unit_level == 3 && current_user.unit.is_facility_management_unit
          low_value_consumption_infos = LowValueConsumptionInfo.where(query_string, lvc_catalog_id, lv3_unit_id, lv4_unit_ids, "in_use", @start_sum).where(relevant_unit_id: current_user.unit.id)
        else
          low_value_consumption_infos = LowValueConsumptionInfo.where(query_string, lvc_catalog_id, lv3_unit_id, lv4_unit_ids, "in_use", @start_sum)
        end
      else
        if current_user.unit.unit_level == 3 && current_user.unit.is_facility_management_unit
          low_value_consumption_infos = LowValueConsumptionInfo.where(query_string, lvc_catalog_id, lv3_unit_id, lv4_unit_ids, "in_use", @start_sum).where("low_value_consumption_infos.sum <= ?", @end_sum).where(relevant_unit_id: current_user.unit.id)
        else
          low_value_consumption_infos = LowValueConsumptionInfo.where(query_string, lvc_catalog_id, lv3_unit_id, lv4_unit_ids, "in_use", @start_sum).where("low_value_consumption_infos.sum <= ?", @end_sum)
        end
      end
# binding.pry      
      if low_value_consumption_infos.blank?
        flash[:alert] = "没有符合条件的低值易耗品"
        redirect_to to_sample_inventory_low_value_consumption_inventories_url and return
      end

      if current_user.unit.unit_level == 3 && current_user.unit.is_facility_management_unit
        relevant_unit_ids = current_user.unit.id
      else
        relevant_unit_ids = low_value_consumption_infos.select(:relevant_unit_id).distinct.map{|o| o.relevant_unit_id}.compact.join(",")
      end

      
      @low_value_consumption_inventory = LowValueConsumptionInventory.create no: params[:low_value_consumption_inventory][:no], name: params[:low_value_consumption_inventory][:name], start_time: params[:low_value_consumption_inventory][:start_time], end_time: params[:low_value_consumption_inventory][:end_time], desc: params[:low_value_consumption_inventory][:desc], status: "waiting", create_user_id: current_user.id, create_unit_id: current_user.unit_id, is_lv2_unit: false, is_sample: true, relevant_unit_ids: relevant_unit_ids, lvc_catalog_id: lvc_catalog_id, sample_unit_id: lv3_unit_id
      
      if !low_value_consumption_infos.blank?
        inventory_unit_id = @low_value_consumption_inventory.low_value_consumption_inventory_units.create(unit_id: lv3_unit_id, status: "unfinished")
      end
        
      low_value_consumption_infos.each do |x|
        @low_value_consumption_inventory.low_value_consumption_inventory_details.create(sn: x.sn, asset_name: x.asset_name, asset_no: x.asset_no, lvc_catalog_id: x.lvc_catalog_id, relevant_unit_id: x.relevant_unit_id, buy_at: x.buy_at, use_at: x.use_at, measurement_unit: x.measurement_unit, sum: x.sum, use_unit_id: x.use_unit_id, branch: x.branch, location: x.location, user: x.user, change_log: x.change_log, consumption_status: x.status, print_times: x.print_times, brand_model: x.brand_model, batch_no: x.batch_no, purchase_id: x.purchase_id, manage_unit_id: x.manage_unit_id, inventory_status: "waiting", lvc_inventory_unit_id: inventory_unit_id, low_value_consumption_info_id: x.id, brand_model: x.brand_model, use_years: x.use_years, desc1: x.desc1)
      end

      respond_to do |format|
        format.html { redirect_to sample_inventory_index_low_value_consumption_inventories_url }
        format.json { head :no_content }
      end
    end
  end

  def to_report
    @units = nil
    @relevant_units = nil
    @inventory = LowValueConsumptionInventory.find(params[:id].to_i)

    if !@inventory.blank?
      if (current_user.unit.unit_level == 1) || (current_user.unit.is_facility_management_unit)
        unit_ids = @inventory.low_value_consumption_inventory_units.select(:unit_id)
      elsif current_user.unit.unit_level == 2
        unit_ids = @inventory.low_value_consumption_inventory_details.where(manage_unit_id: current_user.unit_id).select(:use_unit_id).distinct
      elsif current_user.unit.unit_level == 3 && !current_user.unit.is_facility_management_unit
        unit_ids = @inventory.low_value_consumption_inventory_details.joins(:unit).where("units.id = ? or units.parent_id = ?", current_user.unit_id, current_user.unit_id).select("units.id").distinct
      elsif current_user.unit.unit_level == 4
        unit_ids = current_user.unit_id
      end

      @units = Unit.where(id: unit_ids).order(:unit_level, :no)

      if @inventory.relevant_unit_ids.blank? 
        @relevant_units = Unit.where(is_facility_management_unit: true).order(:no)
      else
        @relevant_units = Unit.where(id: @inventory.relevant_unit_ids.split(",").map(&:to_i))
      end
    end
  end

  def report
    @return_datas = Hash.new
    @results = Hash.new

    @inventory_id = params[:id]
    
    @return_datas = process_params(params)

    @results = get_results(params, @return_datas)
  end

  def process_params(params)
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

  def get_results(params, return_datas)
    sum_amount = Hash.new
    status_amount = Hash.new
    results = Hash.new
    total_amount = 0
    match_amount = 0
    unmatch_amount = 0
    no_scan_amount = 0
    waiting_amount = 0

    if (current_user.unit.unit_level == 1) || (current_user.unit.is_facility_management_unit)
      sum_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ? and manage_unit_id in (?) and relevant_unit_id in (?)", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"]).group(:manage_unit_id).order(:manage_unit_id).count
      status_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ? and manage_unit_id in (?) and relevant_unit_id in (?) and end_date <= ?", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"], return_datas["end_date"]).group(:manage_unit_id).group(:inventory_status).order(:manage_unit_id, :inventory_status).count
    else 
      sum_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ? and use_unit_id in (?) and relevant_unit_id in (?)", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"]).group(:use_unit_id).order(:use_unit_id).count
      status_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ? and use_unit_id in (?) and relevant_unit_id in (?) and end_date <= ?", params[:id].to_i, return_datas["unit_ids"], return_datas["relevant_unit_ids"], return_datas["end_date"]).group(:use_unit_id).group(:inventory_status).order(:use_unit_id, :inventory_status).count
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

  def export
    return_datas = Hash.new
    results = Hash.new
   
    return_datas = process_params(params)

    results = get_results(params, return_datas)

    send_data(report_xls_content_for(return_datas, results), :type => "text/excel;charset=utf-8; header=present", :filename => "报表_#{Time.now.strftime("%Y%m%d")}.xls")  
  end

  def report_xls_content_for(return_datas, results)  
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "报表"  
  
    filter = Spreadsheet::Format.new :size => 10
    title = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center, :weight => :bold
    body = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center

    sheet1.column(0).width = 60
    1.upto(5) do |i|
      sheet1.column(i).width = 20
    end

    sheet1[0,0] = "截止时间: #{return_datas["edate"]}"
    sheet1.row(0).default_format = filter 
    # sheet1[1,0] = "盘点单位: #{return_datas["unit_names"]}"
    # sheet1.row(1).default_format = filter 
    # sheet1[2,0] = "资产归口单位: #{return_datas["relevant_unit_names"]}"
    # sheet1.row(2).default_format = filter 
    
    sheet1.row(2).concat %w{单位 总数 匹配数 不匹配数 未扫描数 待扫描数}  
    0.upto(5) do |i|
      sheet1.row(2).set_format(i, title)
    end
    count_row = 3
    results.each do |k,v|   
      sheet1[count_row,0]=Unit.find(k).try(:name)
      sheet1[count_row,1]=v[0]
      sheet1[count_row,2]=v[1]
      sheet1[count_row,3]=v[2]
      sheet1[count_row,4]=v[3]
      sheet1[count_row,5]=v[4]
      0.upto(5) do |i|
        sheet1.row(count_row).set_format(i, body)
      end

      count_row += 1
    end 

    sheet1[count_row,0]="总计"
    sheet1[count_row,1]=return_datas["total_amount"]
    sheet1[count_row,2]=return_datas["match_amount"]
    sheet1[count_row,3]=return_datas["unmatch_amount"]
    sheet1[count_row,4]=return_datas["no_scan_amount"]
    sheet1[count_row,5]=return_datas["waiting_amount"]

    0.upto(5) do |i|
      sheet1.row(count_row).set_format(i, body)
    end

    book.write xls_report  
    xls_report.string  
  end

  def sample_report
    @end_date = nil
    sum_amount = Hash.new
    status_amount = Hash.new
    @results = Hash.new
    @totals = Hash.new
    

    @inventory = LowValueConsumptionInventory.find(params[:id].to_i)

    unless request.get?
      if !params[:end_date].blank? && !params[:end_date]["end_date"].blank?
        @end_date = to_date(params[:end_date]["end_date"])
      end
      
      sum_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ?", params[:id].to_i).group(:use_unit_id).order(:use_unit_id).count
      status_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ? and end_date <= ?", params[:id].to_i,@end_date.blank? ? nil : (@end_date+1)).group(:use_unit_id).group(:inventory_status).order(:use_unit_id, :inventory_status).count

      sum_amount.each do |k,v|
        match_am = status_amount[[k, "match"]].blank? ? 0 : status_amount[[k, "match"]]
        unmatch_am = status_amount[[k, "unmatch"]].blank? ? 0 : status_amount[[k, "unmatch"]]
        no_scan_am = status_amount[[k, "no_scan"]].blank? ? 0 : status_amount[[k, "no_scan"]]
        waiting_am = v-match_am-unmatch_am-no_scan_am
        @results[k]=[v, match_am, unmatch_am, no_scan_am, waiting_am]
      end
      total_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ?", params[:id].to_i).count
      @totals["total_amount"] = total_amount
      match_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ? and end_date <= ? and inventory_status = ?", params[:id].to_i, @end_date.blank? ? nil : (@end_date+1), "match").count
      @totals["match_amount"] = match_amount
      unmatch_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ? and end_date <= ? and inventory_status = ?", params[:id].to_i,@end_date.blank? ? nil : (@end_date+1), "unmatch").count
      @totals["unmatch_amount"] = unmatch_amount
      no_scan_amount = LowValueConsumptionInventoryDetail.where("lvc_inventory_id = ? and end_date <= ? and inventory_status = ?", params[:id].to_i,@end_date.blank? ? nil : (@end_date+1), "no_scan").count
      @totals["no_scan_amount"] = no_scan_amount
      waiting_amount = total_amount - match_amount - unmatch_amount - no_scan_amount
      @totals["waiting_amount"] = waiting_amount


      if !params[:is_query].blank? and params[:is_query].eql?"true"
        if @results.blank?
          flash[:alert] = "无数据"
        end
        render '/low_value_consumption_inventories/sample_report'
      elsif !params[:is_query].blank? and params[:is_query].eql?"false"
        if @results.blank?
          flash[:alert] = "无数据"
          redirect_to :action => 'sample_report'
        else
          send_data(sample_report_xls_content_for(@end_date, @results, @totals),:type => "text/excel;charset=utf-8; header=present",:filename => "报表_#{Time.now.strftime("%Y%m%d")}.xls")  
        end
      end
    end  

  end

  def sample_report_xls_content_for(end_date, results, totals)  
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "报表"  
  
    filter = Spreadsheet::Format.new :size => 10
    title = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center, :weight => :bold
    body = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center

    sheet1.column(0).width = 60
    1.upto(5) do |i|
      sheet1.column(i).width = 20
    end

    sheet1[0,0] = "截止时间: #{end_date.strftime("%Y-%m-%d")}"
    sheet1.row(0).default_format = filter 
    
    sheet1.row(2).concat %w{单位 总数 匹配数 不匹配数 未扫描数 待扫描数}  
    0.upto(5) do |i|
      sheet1.row(2).set_format(i, title)
    end
    count_row = 3
    results.each do |k,v|   
      sheet1[count_row,0]=Unit.find(k).try(:name)
      sheet1[count_row,1]=v[0]
      sheet1[count_row,2]=v[1]
      sheet1[count_row,3]=v[2]
      sheet1[count_row,4]=v[3]
      sheet1[count_row,5]=v[4]
      0.upto(5) do |i|
        sheet1.row(count_row).set_format(i, body)
      end

      count_row += 1
    end 

    sheet1[count_row,0]="总计"
    sheet1[count_row,1]=totals["total_amount"]
    sheet1[count_row,2]=totals["match_amount"]
    sheet1[count_row,3]=totals["unmatch_amount"]
    sheet1[count_row,4]=totals["no_scan_amount"]
    sheet1[count_row,5]=totals["waiting_amount"]

    0.upto(5) do |i|
      sheet1.row(count_row).set_format(i, body)
    end

    book.write xls_report  
    xls_report.string  
  end


  private
    def set_low_value_consumption_inventory
      @low_value_consumption_inventory = LowValueConsumptionInventory.find(params[:id])
    end

    def low_value_consumption_inventory_params
      params[:low_value_consumption_inventory].permit(:no, :name, :desc, :start_time, :end_time)
    end

    def to_date(time)
      date = Date.civil(time.split(/-|\//)[0].to_i,time.split(/-|\//)[1].to_i,time.split(/-|\//)[2].to_i)
      return date
    end
end
