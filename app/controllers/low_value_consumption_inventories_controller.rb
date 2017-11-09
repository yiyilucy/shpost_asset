class LowValueConsumptionInventoriesController < ApplicationController
  before_action :set_low_value_consumption_inventory, only: [:show, :edit, :update, :destroy]

  def index
    @low_value_consumption_inventories = LowValueConsumptionInventory.all
    respond_with(@low_value_consumption_inventories)
  end

  def show
    respond_with(@low_value_consumption_inventory)
  end

  def new
    @low_value_consumption_inventory = LowValueConsumptionInventory.new
    respond_with(@low_value_consumption_inventory)
  end

  def edit
  end

  def create
    @low_value_consumption_inventory = LowValueConsumptionInventory.new(low_value_consumption_inventory_params)
    @low_value_consumption_inventory.save
    respond_with(@low_value_consumption_inventory)
  end

  def update
    @low_value_consumption_inventory.update(low_value_consumption_inventory_params)
    respond_with(@low_value_consumption_inventory)
  end

  def destroy
    @low_value_consumption_inventory.destroy
    respond_with(@low_value_consumption_inventory)
  end

  private
    def set_low_value_consumption_inventory
      @low_value_consumption_inventory = LowValueConsumptionInventory.find(params[:id])
    end

    def low_value_consumption_inventory_params
      params[:low_value_consumption_inventory]
    end
end
