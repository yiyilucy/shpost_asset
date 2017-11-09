class FixedAssetInventoryDetailsController < ApplicationController
  before_action :set_fixed_asset_inventory_detail, only: [:show, :edit, :update, :destroy]

  def index
    @fixed_asset_inventory_details = FixedAssetInventoryDetail.all
    respond_with(@fixed_asset_inventory_details)
  end

  def show
    respond_with(@fixed_asset_inventory_detail)
  end

  def new
    @fixed_asset_inventory_detail = FixedAssetInventoryDetail.new
    respond_with(@fixed_asset_inventory_detail)
  end

  def edit
  end

  def create
    @fixed_asset_inventory_detail = FixedAssetInventoryDetail.new(fixed_asset_inventory_detail_params)
    @fixed_asset_inventory_detail.save
    respond_with(@fixed_asset_inventory_detail)
  end

  def update
    @fixed_asset_inventory_detail.update(fixed_asset_inventory_detail_params)
    respond_with(@fixed_asset_inventory_detail)
  end

  def destroy
    @fixed_asset_inventory_detail.destroy
    respond_with(@fixed_asset_inventory_detail)
  end

  def recheck
    @fixed_asset_inventory_detail = nil
    @fixed_asset_inventory = nil
    @fixed_asset_inventory_unit = nil

    if !params.blank? and !params[:id].blank?
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id].to_i)
      if !@fixed_asset_inventory_detail.blank?
        @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory 
        # @fixed_asset_inventory_unit = FixedAssetInventoryUnit.find_by(unit_id: @fixed_asset_inventory_detail.unit_id) if !@fixed_asset_inventory_detail.unit_id.blank?
        @fixed_asset_inventory_unit = @fixed_asset_inventory_detail.fixed_asset_inventory_unit

        @fixed_asset_inventory_detail.update inventory_status: "waiting", is_check: true
        @fixed_asset_inventory.update status: "doing"
        @fixed_asset_inventory_unit.update status: "unfinished" if !@fixed_asset_inventory_unit.blank?

        respond_to do |format|
          format.html { redirect_to fixed_asset_inventory_fixed_asset_inventory_details_path(@fixed_asset_inventory) }
          format.json { head :no_content }
        end
      end
    end
    
    
  end

  def scan
    @fixed_asset_inventory_detail = nil
    @fixed_asset_inventory = nil
    if !params.blank? and !params[:id].blank?
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id].to_i)
      @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory if !@fixed_asset_inventory_detail.blank?
    end
  end

  def match
    @fixed_asset_inventory_detail = nil
    @fixed_asset_inventory = nil
    if !params.blank? and !params[:id].blank?
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id].to_i)
      @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory if !@fixed_asset_inventory_detail.blank?
      @fixed_asset_inventory_detail.update inventory_status: "match"

    end
    respond_to do |format|
      format.html { redirect_to doing_index_fixed_asset_inventory_fixed_asset_inventory_details_path(@fixed_asset_inventory) }
      format.json { head :no_content }
    end
  end

  def unmatch
    @fixed_asset_inventory_detail = nil
    @fixed_asset_inventory = nil
    if !params.blank? and !params[:id].blank?
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id].to_i)
      if !@fixed_asset_inventory_detail.blank?
        @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory 
        # binding.pry
        @fixed_asset_inventory_detail.update inventory_status: "unmatch", desc: params[:desc_content].blank? ? "" : params[:desc_content]
      end
    end
    respond_to do |format|
      format.html { redirect_to doing_index_fixed_asset_inventory_fixed_asset_inventory_details_path(@fixed_asset_inventory) }
      format.json { head :no_content }
    end
  end

  private
    def set_fixed_asset_inventory_detail
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id])
    end

    def fixed_asset_inventory_detail_params
      params[:fixed_asset_inventory_detail]
    end
end
