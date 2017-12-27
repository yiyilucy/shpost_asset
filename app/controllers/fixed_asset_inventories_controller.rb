class FixedAssetInventoriesController < ApplicationController
  load_and_authorize_resource

  def index
    @fixed_asset_inventories = FixedAssetInventory.where(create_user_id: current_user.id)
    @fixed_asset_inventories_grid = initialize_grid(@fixed_asset_inventories, order: 'fixed_asset_inventories.created_at',
      order_direction: 'desc')
  end

  def doing_index
    if current_user.unit.unit_level == 2
      @fixed_asset_inventories = FixedAssetInventory.includes(:fixed_asset_inventory_units).where("fixed_asset_inventories.status in (?) and fixed_asset_inventory_units.unit_id = ? and fixed_asset_inventories.create_unit_id != ?", ["doing", "canceled", "done"], current_user.unit_id, current_user.unit_id)
    elsif current_user.unit.unit_level == 3
      @fixed_asset_inventories = FixedAssetInventory.includes(:fixed_asset_inventory_units).where("fixed_asset_inventories.status in (?) and fixed_asset_inventory_units.unit_id = ?", ["doing", "canceled", "done"], current_user.unit.parent_id)
    end
    
    @fixed_asset_inventories_grid = initialize_grid(@fixed_asset_inventories, order: 'fixed_asset_inventories.created_at',
      order_direction: 'desc')
  end

  def show
  end

  def new
    @inventory = FixedAssetInventory.new
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
    ActiveRecord::Base.transaction do
      if !params[:g1].nil?
        units = params[:g1][:selected]
      end
      if !params[:g2].nil?
        relevant_departments = params[:g2][:selected]
      end
      if units.blank?
        flash[:alert] = "请先选择盘点单位"
        redirect_to fixed_asset_inventories_url and return
      end
      if relevant_departments.blank?
        flash[:alert] = "请先选择资产归口单位"
        redirect_to fixed_asset_inventories_url and return
      end

      # if current_user.unit.unit_level == 1 or current_user.unit.is_facility_management_unit
      #   fixed_asset_infos = FixedAssetInfo.where(relevant_department: relevant_departments, manage_unit_id: units)
      # elsif current_user.unit.unit_level == 2
      #   fixed_asset_infos = FixedAssetInfo.where(relevant_department: relevant_departments, unit_id: units)
      # end
# binding.pry
      if current_user.unit.unit_level == 2
        fixed_asset_infos = FixedAssetInfo.where("fixed_asset_infos.relevant_unit_id in (?) and fixed_asset_infos.unit_id in (?) and fixed_asset_infos.status = ?", relevant_departments, units, "in_use")
      else
        fixed_asset_infos = FixedAssetInfo.where("fixed_asset_infos.relevant_unit_id in (?) and (fixed_asset_infos.unit_id in (?) or fixed_asset_infos.manage_unit_id in (?)) and fixed_asset_infos.status = ?", relevant_departments, units, units, "in_use")
      end

      if fixed_asset_infos.blank?
        flash[:alert] = "没有符合条件的固定资产"
        redirect_to fixed_asset_inventories_url and return
      end

      if !params[:fixed_asset_inventory].blank?
        if params[:fixed_asset_inventory][:start_time].blank? or params[:fixed_asset_inventory][:end_time].blank?
          flash[:alert] = "请选择盘点开始时间和结束时间"
          redirect_to fixed_asset_inventories_url and return
        end
# binding.pry
        fainventories = FixedAssetInventory.includes(:fixed_asset_inventory_units).where("fixed_asset_inventory_units.unit_id in (?) and fixed_asset_inventories.start_time <= ? and fixed_asset_inventories.status in (?)", units, DateTime.parse(params[:fixed_asset_inventory][:start_time]), ["waiting", "doing"])
        if !fainventories.blank?
          flash[:alert] = "同一时间同一单位不可重叠盘点"
          redirect_to fixed_asset_inventories_url and return
        end
        
        @fixed_asset_inventory.no = params[:fixed_asset_inventory][:no]
        @fixed_asset_inventory.name = params[:fixed_asset_inventory][:name]
        @fixed_asset_inventory.start_time = params[:fixed_asset_inventory][:start_time]
        @fixed_asset_inventory.end_time = params[:fixed_asset_inventory][:end_time]
        @fixed_asset_inventory.desc = params[:fixed_asset_inventory][:desc]
        @fixed_asset_inventory.status = "waiting"
        @fixed_asset_inventory.create_user_id = current_user.id
        @fixed_asset_inventory.create_unit_id = current_user.unit_id

        if current_user.unit.unit_level == 2
          @fixed_asset_inventory.is_lv2_unit = true
        end

        @fixed_asset_inventory.save

        Unit.where(id: units).each do |x|
          if @fixed_asset_inventory.is_lv2_unit
            if !FixedAssetInfo.where("fixed_asset_infos.relevant_unit_id in (?) and fixed_asset_infos.unit_id = ? and fixed_asset_infos.status = ?", relevant_departments, x.id, "in_use").blank?
              @fixed_asset_inventory.fixed_asset_inventory_units.create(unit_id: x.id, status: "unfinished")
            end
          else
            if !FixedAssetInfo.where("fixed_asset_infos.relevant_unit_id in (?) and (fixed_asset_infos.unit_id = ? or fixed_asset_infos.manage_unit_id = ?) and fixed_asset_infos.status = ?", relevant_departments, x.id, x.id, "in_use").blank?
              @fixed_asset_inventory.fixed_asset_inventory_units.create(unit_id: x.id, status: "unfinished")
            end
          end
        end
          
        fixed_asset_infos.each do |x|
          if @fixed_asset_inventory.is_lv2_unit
            inventory_unit_id = FixedAssetInventoryUnit.find_by(fixed_asset_inventory_id: @fixed_asset_inventory.id, unit_id: x.unit_id).blank? ? nil : FixedAssetInventoryUnit.find_by(fixed_asset_inventory_id: @fixed_asset_inventory.id, unit_id: x.unit_id).id
          else
            inventory_unit_id = FixedAssetInventoryUnit.find_by(fixed_asset_inventory_id: @fixed_asset_inventory.id, unit_id: x.manage_unit_id).blank? ? nil : FixedAssetInventoryUnit.find_by(fixed_asset_inventory_id: @fixed_asset_inventory.id, unit_id: x.manage_unit_id).id
          end

          @fixed_asset_inventory.fixed_asset_inventory_details.create(sn: x.sn, asset_name: x.asset_name, asset_no: x.asset_no, fixed_asset_catalog_id: x.fixed_asset_catalog_id, relevant_unit_id: x.relevant_unit_id, buy_at: x.buy_at, use_at: x.use_at, measurement_unit: x.measurement_unit, amount: x.amount, sum: x.sum, unit_id: x.unit_id, branch: x.branch, location: x.location, user: x.user, change_log: x.change_log, accounting_department: x.accounting_department, asset_status: x.status, print_times: x.print_times, manage_unit_id: x.manage_unit_id, inventory_status: "waiting", fixed_asset_inventory_unit_id: inventory_unit_id, fixed_asset_info_id: x.id, brand_model: x.brand_model, use_years: x.use_years, desc1: x.desc1, belong_unit: x.belong_unit)
        end

        
      end

      respond_to do |format|
        format.html { redirect_to fixed_asset_inventories_url }
        format.json { head :no_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @fixed_asset_inventory.update(fixed_asset_inventory_params)
        format.html { redirect_to @fixed_asset_inventory, notice: I18n.t('controller.update_success_notice', model: '固定资产盘点单') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @fixed_asset_inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @fixed_asset_inventory.destroy
    respond_to do |format|
      format.html { redirect_to fixed_asset_inventories_url }
      format.json { head :no_content }
    end
  end

  def cancel
    @fixed_asset_inventory.update status: "canceled"

    respond_to do |format|
      format.html { redirect_to fixed_asset_inventories_url }
      format.json { head :no_content }
    end
  end

  def done
    all_finished = true

    if current_user.unit.unit_level == 2
      @fixed_asset_inventory.fixed_asset_inventory_details.each do |x|
        if x.inventory_status.eql?"waiting"
          # all_finished = false
          x.update inventory_status: "no_scan"
        end
      end
    elsif current_user.unit.is_facility_management_unit or current_user.unit.unit_level == 1
      @fixed_asset_inventory.fixed_asset_inventory_units.each do |x|
        if x.status.eql?"unfinished"
          all_finished = false
        end
      end
    end

    if all_finished
      @fixed_asset_inventory.update status: "done"
    else
      flash[:alert] = "请等待所有参与单位都完成后再点击"
    end

    respond_to do |format|
      format.html { redirect_to fixed_asset_inventories_url }
      format.json { head :no_content }
    end
  end

  def sub_done
    sub_unit = @fixed_asset_inventory.fixed_asset_inventory_units.find_by(unit_id: current_user.unit_id)

    if !sub_unit.blank?
    #   all_scanned = true
      fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.where(manage_unit_id: current_user.unit_id)

      fixed_asset_inventory_details.each do |x|
        if x.inventory_status.eql?"waiting"
          # all_scanned = false
          x.update inventory_status: "no_scan"
        end
      end

    #   if all_scanned
        sub_unit.update status: "finished"
    #   else
    #     flash[:alert] = "固定资产盘点未全部完成"
    #   end
    end

    respond_to do |format|
      format.html { redirect_to doing_index_fixed_asset_inventories_url }
      format.json { head :no_content }
    end
  end

  

  private
    def set_fixed_asset_inventory
      @fixed_asset_inventory = FixedAssetInventory.find(params[:id])
    end

    def fixed_asset_inventory_params
      params[:fixed_asset_inventory].permit(:no, :name, :desc, :start_time, :end_time)
    end
end
