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

  private
    def set_low_value_consumption_inventory_detail
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id])
    end

    def low_value_consumption_inventory_detail_params
      params[:low_value_consumption_inventory_detail]
    end
end
