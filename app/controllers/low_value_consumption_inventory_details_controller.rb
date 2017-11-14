class LowValueConsumptionInventoryDetailsController < ApplicationController
  before_action :set_low_value_consumption_inventory_detail, only: [:show, :edit, :update, :destroy]

  def index
    @low_value_consumption_inventory_details = LowValueConsumptionInventoryDetail.all
    respond_with(@low_value_consumption_inventory_details)
  end

  def show
    respond_with(@low_value_consumption_inventory_detail)
  end

  def new
    @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.new
    respond_with(@low_value_consumption_inventory_detail)
  end

  def edit
  end

  def create
    @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.new(low_value_consumption_inventory_detail_params)
    @low_value_consumption_inventory_detail.save
    respond_with(@low_value_consumption_inventory_detail)
  end

  def update
    @low_value_consumption_inventory_detail.update(low_value_consumption_inventory_detail_params)
    respond_with(@low_value_consumption_inventory_detail)
  end

  def destroy
    @low_value_consumption_inventory_detail.destroy
    respond_with(@low_value_consumption_inventory_detail)
  end

  def recheck
    @low_value_consumption_inventory_detail = nil
    @low_value_consumption_inventory = nil
    @low_value_consumption_inventory_unit = nil

    if !params.blank? and !params[:id].blank?
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id].to_i)
      if !@low_value_consumption_inventory_detail.blank?
        @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory 
        @low_value_consumption_inventory_unit = @low_value_consumption_inventory_detail.low_value_consumption_inventory_unit

        @low_value_consumption_inventory_detail.update inventory_status: "waiting", is_check: true
        @low_value_consumption_inventory.update status: "doing"
        @low_value_consumption_inventory_unit.update status: "unfinished" if !@low_value_consumption_inventory_unit.blank?

        respond_to do |format|
          format.html { redirect_to low_value_consumption_inventory_low_value_consumption_inventory_details_path(@low_value_consumption_inventory) }
          format.json { head :no_content }
        end
      end
    end
    
    
  end

  def scan
    @low_value_consumption_inventory_detail = nil
    @low_value_consumption_inventory = nil
    if !params.blank? and !params[:id].blank?
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id].to_i)
      @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory if !@low_value_consumption_inventory_detail.blank?
    end
  end

  def match
    @low_value_consumption_inventory_detail = nil
    @low_value_consumption_inventory = nil
    if !params.blank? and !params[:id].blank?
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id].to_i)
      @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory if !@low_value_consumption_inventory_detail.blank?
      @low_value_consumption_inventory_detail.update inventory_status: "match"

    end
    respond_to do |format|
      format.html { redirect_to doing_index_low_value_consumption_inventory_low_value_consumption_inventory_details_path(@low_value_consumption_inventory) }
      format.json { head :no_content }
    end
  end

  def unmatch
    @low_value_consumption_inventory_detail = nil
    @low_value_consumption_inventory = nil
    if !params.blank? and !params[:id].blank?
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id].to_i)
      if !@low_value_consumption_inventory_detail.blank?
        @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory 
        # binding.pry
        @low_value_consumption_inventory_detail.update inventory_status: "unmatch", desc: params[:desc_content].blank? ? "" : params[:desc_content]
      end
    end
    respond_to do |format|
      format.html { redirect_to doing_index_low_value_consumption_inventory_low_value_consumption_inventory_details_path(@low_value_consumption_inventory) }
      format.json { head :no_content }
    end
  end

  

  private
    def set_low_value_consumption_inventory_detail
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id])
    end

    def low_value_consumption_inventory_detail_params
      params[:low_value_consumption_inventory_detail]
    end
end
