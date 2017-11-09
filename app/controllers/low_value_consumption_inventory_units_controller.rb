class LowValueConsumptionInventoryUnitsController < ApplicationController
  before_action :set_low_value_consumption_inventory_unit, only: [:show, :edit, :update, :destroy]

  def index
    @low_value_consumption_inventory_units = LowValueConsumptionInventoryUnit.all
    respond_with(@low_value_consumption_inventory_units)
  end

  def show
    respond_with(@low_value_consumption_inventory_unit)
  end

  def new
    @low_value_consumption_inventory_unit = LowValueConsumptionInventoryUnit.new
    respond_with(@low_value_consumption_inventory_unit)
  end

  def edit
  end

  def create
    @low_value_consumption_inventory_unit = LowValueConsumptionInventoryUnit.new(low_value_consumption_inventory_unit_params)
    @low_value_consumption_inventory_unit.save
    respond_with(@low_value_consumption_inventory_unit)
  end

  def update
    @low_value_consumption_inventory_unit.update(low_value_consumption_inventory_unit_params)
    respond_with(@low_value_consumption_inventory_unit)
  end

  def destroy
    @low_value_consumption_inventory_unit.destroy
    respond_with(@low_value_consumption_inventory_unit)
  end

  private
    def set_low_value_consumption_inventory_unit
      @low_value_consumption_inventory_unit = LowValueConsumptionInventoryUnit.find(params[:id])
    end

    def low_value_consumption_inventory_unit_params
      params[:low_value_consumption_inventory_unit]
    end
end
