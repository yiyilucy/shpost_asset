class RentInventoryDetailsController < ApplicationController
  before_action :set_rent_inventory_detail, only: [:show, :edit, :update, :destroy]

  def index
    @rent_inventory_details = RentInventoryDetail.all
    respond_with(@rent_inventory_details)
  end

  def show
    respond_with(@rent_inventory_detail)
  end

  def new
    @rent_inventory_detail = RentInventoryDetail.new
    respond_with(@rent_inventory_detail)
  end

  def edit
  end

  def create
    @rent_inventory_detail = RentInventoryDetail.new(rent_inventory_detail_params)
    @rent_inventory_detail.save
    respond_with(@rent_inventory_detail)
  end

  def update
    @rent_inventory_detail.update(rent_inventory_detail_params)
    respond_with(@rent_inventory_detail)
  end

  def destroy
    @rent_inventory_detail.destroy
    respond_with(@rent_inventory_detail)
  end

  def recheck
    @rent_inventory_detail = nil
    @rent_inventory = nil
    @rent_inventory_unit = nil

    if !params.blank? and !params[:id].blank?
      @rent_inventory_detail = RentInventoryDetail.find(params[:id].to_i)
      if !@rent_inventory_detail.blank?
        @rent_inventory = @rent_inventory_detail.rent_inventory 
        @rent_inventory_unit = @rent_inventory_detail.rent_inventory_unit

        LowValueConsumptionInventoryDetail.recheck(@rent_inventory_detail, @rent_inventory, @rent_inventory_unit)

        respond_to do |format|
          format.html { redirect_to rent_inventory_rent_inventory_details_path(@rent_inventory) }
          format.json { head :no_content }
        end
      end
    end
  end

  def scan
    @rent_inventory_detail = nil
    @rent_inventory = nil
    if !params.blank? and !params[:id].blank?
      @rent_inventory_detail = RentInventoryDetail.find(params[:id].to_i)
      @rent_inventory = @rent_inventory_detail.rent_inventory if !@rent_inventory_detail.blank?
    end
  end

  def match
    @rent_inventory_detail = nil
    @rent_inventory = nil
    if !params.blank? and !params[:id].blank?
      @rent_inventory_detail = RentInventoryDetail.find(params[:id].to_i)
      @rent_inventory = @rent_inventory_detail.rent_inventory if !@rent_inventory_detail.blank?
      @rent_inventory_detail.update inventory_status: "match", inventory_user_id: current_user.id, end_date: Time.now

    end
    respond_to do |format|
      format.html { redirect_to scan_rent_inventory_detail_path(@rent_inventory_detail) }
      format.json { head :no_content }
    end
  end

  def unmatch
    @rent_inventory_detail = nil
    @rent_inventory = nil
    if !params.blank? and !params[:id].blank?
      @rent_inventory_detail = RentInventoryDetail.find(params[:id].to_i)
      if !@rent_inventory_detail.blank?
        @rent_inventory = @rent_inventory_detail.rent_inventory 
        @rent_inventory_detail.update inventory_status: "unmatch", desc: (params[:desc_content].blank? ? "" : params[:desc_content]), inventory_user_id: current_user.id, end_date: Time.now
      end
    end
    respond_to do |format|
      format.html { redirect_to scan_rent_inventory_detail_path(@rent_inventory_detail) }
      format.json { head :no_content }
    end
  end


  private
    def set_rent_inventory_detail
      @rent_inventory_detail = RentInventoryDetail.find(params[:id])
    end

    def rent_inventory_detail_params
      params[:rent_inventory_detail]
    end
end
