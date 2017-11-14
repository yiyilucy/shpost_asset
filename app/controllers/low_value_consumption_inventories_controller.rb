class LowValueConsumptionInventoriesController < ApplicationController
  load_and_authorize_resource

  def index
    @low_value_consumption_inventories = LowValueConsumptionInventory.where(create_user_id: current_user.id)
    @low_value_consumption_inventories_grid = initialize_grid(@low_value_consumption_inventories, order: 'low_value_consumption_inventories.created_at',
      order_direction: 'desc')
  end

  def doing_index
    @low_value_consumption_inventories = LowValueConsumptionInventory.includes(:low_value_consumption_inventory_units).where("low_value_consumption_inventories.status in (?) and low_value_consumption_inventory_units.unit_id = ? and low_value_consumption_inventories.create_unit_id != ?", ["doing", "canceled", "done"], current_user.unit_id, current_user.unit_id)
    
    @low_value_consumption_inventories_grid = initialize_grid(@low_value_consumption_inventories, order: 'low_value_consumption_inventories.created_at',
      order_direction: 'desc')
  end

  def show
  end

  def new
    @inventory = LowValueConsumptionInventory.new
    if current_user.unit.unit_level == 1
      @units_grid = initialize_grid(Unit.where(unit_level: 2, is_facility_management_unit: false).order(:no),:name => 'g1')
      @relevant_departments_grid = initialize_grid(Unit.where(is_facility_management_unit: true, unit_level: 2).order(:no),:name => 'g2')
    elsif current_user.unit.unit_level == 2 and current_user.unit.is_facility_management_unit
      @units_grid = initialize_grid(Unit.where(unit_level: 2, is_facility_management_unit: false).order(:no),:name => 'g1')
      @relevant_departments_grid = initialize_grid(Unit.where(id: current_user.unit_id),:name => 'g2')
    elsif current_user.unit.unit_level == 2 and !current_user.unit.is_facility_management_unit
      lv3units = Unit.where(parent_id: current_user.unit_id).select(:id)
      @units_grid = initialize_grid(Unit.where("parent_id = ? or id = ? or parent_id in (?)", current_user.unit_id, current_user.unit_id, lv3units).order(:unit_level, :no),:name => 'g1')
      @relevant_departments_grid = initialize_grid(Unit.where(is_facility_management_unit: true, unit_level: 2).order(:no),:name => 'g2')
    end
  end

  def edit
  end

  def create
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

      
# binding.pry
      if current_user.unit.unit_level == 2 and !current_user.unit.is_facility_management_unit
        low_value_consumption_infos = LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and low_value_consumption_infos.use_unit_id in (?)", relevant_departments, units)
      else
        low_value_consumption_infos = LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and (low_value_consumption_infos.use_unit_id in (?) or low_value_consumption_infos.manage_unit_id in (?))", relevant_departments, units, units)
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
# binding.pry
        lvinventories = LowValueConsumptionInventory.includes(:low_value_consumption_inventory_units).where("low_value_consumption_inventory_units.unit_id in (?) and low_value_consumption_inventories.start_time <= ? and low_value_consumption_inventories.end_time >= ? and low_value_consumption_inventories.status in (?)", units, DateTime.parse(params[:low_value_consumption_inventory][:start_time]), DateTime.parse(params[:low_value_consumption_inventory][:end_time]), ["waiting", "doing"])
        if !lvinventories.blank?
          flash[:alert] = "同一时间同一单位不可重叠盘点"
          redirect_to low_value_consumption_inventories_url and return
        end
        
        @low_value_consumption_inventory.no = params[:low_value_consumption_inventory][:no]
        @low_value_consumption_inventory.name = params[:low_value_consumption_inventory][:name]
        @low_value_consumption_inventory.start_time = params[:low_value_consumption_inventory][:start_time]
        @low_value_consumption_inventory.end_time = params[:low_value_consumption_inventory][:end_time]
        @low_value_consumption_inventory.desc = params[:low_value_consumption_inventory][:desc]
        @low_value_consumption_inventory.status = "waiting"
        @low_value_consumption_inventory.create_user_id = current_user.id
        @low_value_consumption_inventory.create_unit_id = current_user.unit_id

        if current_user.unit.unit_level == 2 and !current_user.unit.is_facility_management_unit
          @low_value_consumption_inventory.is_lv2_unit = true
        end

        @low_value_consumption_inventory.save

        Unit.where(id: units).each do |x|
          if @low_value_consumption_inventory.is_lv2_unit
            if !LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and low_value_consumption_infos.use_unit_id = ?", relevant_departments, x.id).blank?
              @low_value_consumption_inventory.low_value_consumption_inventory_units.create(unit_id: x.id, status: "unfinished")
            end
          else
            if !LowValueConsumptionInfo.where("low_value_consumption_infos.relevant_unit_id in (?) and (low_value_consumption_infos.use_unit_id = ? or low_value_consumption_infos.manage_unit_id = ?)", relevant_departments, x.id, x.id).blank?
              @low_value_consumption_inventory.low_value_consumption_inventory_units.create(unit_id: x.id, status: "unfinished")
            end
          end
        end
          
        low_value_consumption_infos.each do |x|
          if @low_value_consumption_inventory.is_lv2_unit
            inventory_unit_id = LowValueConsumptionInventoryUnit.find_by(low_value_consumption_inventory_id: @low_value_consumption_inventory.id, unit_id: x.use_unit_id).blank? ? nil : LowValueConsumptionInventoryUnit.find_by(low_value_consumption_inventory_id: @low_value_consumption_inventory.id, unit_id: x.use_unit_id).id
          else
            inventory_unit_id = LowValueConsumptionInventoryUnit.find_by(low_value_consumption_inventory_id: @low_value_consumption_inventory.id, unit_id: x.manage_unit_id).blank? ? nil : LowValueConsumptionInventoryUnit.find_by(low_value_consumption_inventory_id: @low_value_consumption_inventory.id, unit_id: x.manage_unit_id).id
          end

          @low_value_consumption_inventory.low_value_consumption_inventory_details.create(sn: x.sn, asset_name: x.asset_name, asset_no: x.asset_no, low_value_consumption_catalog_id: x.low_value_consumption_catalog_id, relevant_unit_id: x.relevant_unit_id, buy_at: x.buy_at, use_at: x.use_at, measurement_unit: x.measurement_unit, sum: x.sum, use_unit_id: x.use_unit_id, branch: x.branch, location: x.location, user: x.user, change_log: x.change_log, consumption_status: x.status, print_times: x.print_times, brand_model: x.brand_model, batch_no: x.batch_no, purchase_id: x.purchase_id, manage_unit_id: x.manage_unit_id, inventory_status: "waiting", low_value_consumption_inventory_unit_id: inventory_unit_id, low_value_consumption_info_id: x.id)
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

    respond_to do |format|
      format.html { redirect_to low_value_consumption_inventories_url }
      format.json { head :no_content }
    end
  end

  def done
    all_finished = true

    if current_user.unit.unit_level == 2 and !current_user.unit.is_facility_management_unit
      @low_value_consumption_inventory.low_value_consumption_inventory_details.each do |x|
        if x.inventory_status.eql?"waiting"
          all_finished = false
        end
      end
    else
      @low_value_consumption_inventory.low_value_consumption_inventory_units.each do |x|
        if x.status.eql?"unfinished"
          all_finished = false
        end
      end
    end

    if all_finished
      @low_value_consumption_inventory.update status: "done"
    else
      flash[:alert] = "请等待所有参与单位都完成后再点击"
    end

    respond_to do |format|
      format.html { redirect_to low_value_consumption_inventories_url }
      format.json { head :no_content }
    end
  end

  def sub_done
    sub_unit = @low_value_consumption_inventory.low_value_consumption_inventory_units.find_by(unit_id: current_user.unit_id)

    if !sub_unit.blank?
      all_scanned = true
      low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.where(manage_unit_id: current_user.unit_id)

      low_value_consumption_inventory_details.each do |x|
        if x.inventory_status.eql?"waiting"
          all_scanned = false
        end
      end

      if all_scanned
        sub_unit.update status: "finished"
      else
        flash[:alert] = "低值易耗品盘点未全部完成"
      end
    end

    respond_to do |format|
      format.html { redirect_to doing_index_low_value_consumption_inventories_url }
      format.json { head :no_content }
    end
  end

  private
    def set_low_value_consumption_inventory
      @low_value_consumption_inventory = LowValueConsumptionInventory.find(params[:id])
    end

    def low_value_consumption_inventory_params
      params[:low_value_consumption_inventory].permit(:no, :name, :desc, :start_time, :end_time)
    end
end
