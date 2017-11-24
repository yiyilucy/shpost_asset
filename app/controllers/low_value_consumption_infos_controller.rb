class LowValueConsumptionInfosController < ApplicationController
  load_and_authorize_resource
  # attr_reader :records

  def index
    if current_user.unit.blank?
      @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "in_use").order(:relevant_unit_id, :manage_unit_id, :asset_no)
    else
      if current_user.unit.unit_level == 1
        @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "in_use").order(:relevant_unit_id, :manage_unit_id, :asset_no)
      elsif current_user.unit.unit_level == 2 and current_user.unit.is_facility_management_unit
        @low_value_consumption_infos = LowValueConsumptionInfo.where(relevant_unit_id: current_user.unit_id, status: "in_use").order(:manage_unit_id, :asset_no)
      elsif current_user.unit.unit_level == 2 and !current_user.unit.is_facility_management_unit
        @low_value_consumption_infos = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").order(:asset_no)
      end
    end

    @low_value_consumption_infos_grid = initialize_grid(@low_value_consumption_infos,
      :name => 'low_value_consumption_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_infos')


    # @records = []

    # binding.pry

    # @low_value_consumption_infos_grid.with_paginated_resultset do |records|
    #   records.each do |rec| 
    #     # binding.pry
    #     @records << rec
    #   end
    # end
    export_grid_if_requested
  end

  def discard_index
    if current_user.unit.blank?
      @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "discard").order(:relevant_unit_id, :manage_unit_id, :asset_no)
    else
      if current_user.unit.unit_level == 1
        @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "discard").order(:relevant_unit_id, :manage_unit_id, :asset_no)
      elsif current_user.unit.unit_level == 2 and current_user.unit.is_facility_management_unit
        @low_value_consumption_infos = LowValueConsumptionInfo.where(relevant_unit_id: current_user.unit_id, status: "discard").order(:manage_unit_id, :asset_no)
      elsif current_user.unit.unit_level == 2 and !current_user.unit.is_facility_management_unit
        @low_value_consumption_infos = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "discard").order(:asset_no)
      end
    end
    
    @low_value_consumption_infos_grid = initialize_grid(@low_value_consumption_infos,
      :name => 'discard_low_value_consumption_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_infos')
  end

  def show
  end

  def new
    # @low_value_consumption_info = LowValueConsumptionInfo.new
  end

  def edit
    @relename=Unit.find_by(id: @low_value_consumption_info.relevant_unit_id).try(:name)
    @usename = Unit.find_by(id: @low_value_consumption_info.use_unit_id).try(:name)
  end

  def create
    respond_to do |format|
      if @low_value_consumption_info.save
        format.html { redirect_to @low_value_consumption_infos, notice: I18n.t('controller.create_success_notice', model: '低值易耗品信息') }
        format.json { render action: 'show', status: :created, location: @low_value_consumption_info }
      else
        format.html { render action: 'new' }
        format.json { render json: @low_value_consumption_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @low_value_consumption_info.update(low_value_consumption_info_params)
        if @low_value_consumption_info.status.eql?"in_use"
          @low_value_consumption_info.update log: (@low_value_consumption_info.log.blank? ? "" : @low_value_consumption_info.log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"低值易耗品信息修改" + ","
        end
        format.html { redirect_to @low_value_consumption_info, notice: I18n.t('controller.update_success_notice', model: '低值易耗品信息')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @low_value_consumption_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @low_value_consumption_info.destroy
    respond_to do |format|
      format.html { redirect_to low_value_consumption_infos_url }
      format.json { head :no_content }
    end
  end

  def print
    if params[:low_value_consumption_infos] && params[:low_value_consumption_infos][:selected]
      @selected = params[:low_value_consumption_infos][:selected]
    else
      flash[:alert] = "请勾选需要打印的低值易耗品"
      respond_to do |format|
        format.html { redirect_to low_value_consumption_infos_url }
        format.json { head :no_content }
      end
    end

    # binding.pry
  end

  def to_scan
    @low_value_consumption_info = nil
    
    if !params.blank? and !params[:id].blank?
      @low_value_consumption_info = LowValueConsumptionInfo.find(params[:id].to_i)
      @low_value_consumption_inventory_detail =LowValueConsumptionInventoryDetail.find_by(low_value_consumption_info_id: @low_value_consumption_info.id)

      if !@low_value_consumption_inventory_detail.blank?
        @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory

        respond_to do |format|
          format.html { redirect_to scan_low_value_consumption_inventory_detail_path(@low_value_consumption_inventory) }
          format.json { head :no_content }
        end
      end
    end
  end

  def batch_edit
    @relename = ''
    @usename = ''
    @low_value_consumption_catalog = ''
    @lvcids = ""
# binding.pry
 
    if !params["low_value_consumption_infos"].blank? and !params["low_value_consumption_infos"]["selected"].blank?
      @lvcids = params["low_value_consumption_infos"]["selected"].compact.join(",")
      @low_value_consumption_info = LowValueConsumptionInfo.find(params["low_value_consumption_infos"]["selected"].first.to_i)
    
      if !@low_value_consumption_info.relevant_unit_id.blank?
        @relename = Unit.find_by(id: @low_value_consumption_info.relevant_unit_id).try(:name)
      end
      if !@low_value_consumption_info.use_unit_id.blank?
        @usename = Unit.find_by(id: @low_value_consumption_info.use_unit_id).try(:name)
      end
      @low_value_consumption_catalog = LowValueConsumptionCatalog.find_by(id: @low_value_consumption_info.lvc_catalog_id).try(:name)
    else
      respond_to do |format|
          format.html { redirect_to low_value_consumption_infos_url, alert: "请勾选低值易耗品" }
          format.json { head :no_content }
      end
    end
  end

  def batch_update
    ActiveRecord::Base.transaction do
      # binding.pry
      if !params[:lvcids].blank?
        params[:lvcids].split(",").map(&:to_i).each do |id|
          @low_value_consumption_info = LowValueConsumptionInfo.find_by(id:id.to_i)
          @low_value_consumption_info.location = params[:location]
          @low_value_consumption_info.user = params[:user]
          @low_value_consumption_info.relevant_unit_id = params[:low_value_consumption_info][:relevant_unit_id]
          @low_value_consumption_info.use_unit_id = params[:low_value_consumption_info][:use_unit_id]
          @low_value_consumption_info.update log: (@low_value_consumption_info.log.blank? ? "" : @low_value_consumption_info.log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"低值易耗品信息批量修改" + ","
          @low_value_consumption_info.save
        end
        flash[:notice] = "批量修改成功"
        redirect_to low_value_consumption_infos_path
      else
        flash[:alert] = "请勾选低值易耗品"
        redirect_to low_value_consumption_infos_path
      end
    end
  end

  def discard
    @low_value_consumption_info.update status: "discard", discard_at: Time.now, log: (@low_value_consumption_info.log.blank? ? "" : @low_value_consumption_info.log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"低值易耗品信息报废" + ","

    respond_to do |format|
      format.html { redirect_to low_value_consumption_infos_url }
      format.json { head :no_content }
    end
  end


  private
    def set_low_value_consumption_info
      @low_value_consumption_info = LowValueConsumptionInfo.find(params[:id])
    end

    def low_value_consumption_info_params
      params.require(:low_value_consumption_info).permit(:asset_name, :asset_no, :fixed_asset_catalog_id, :relevant_unit_id, :buy_at, :use_at, :measurement_unit, :sum, :use_unit_id, :branch, :location, :user, :brand_model, :batch_no, :manage_unit_id)
    end
end
