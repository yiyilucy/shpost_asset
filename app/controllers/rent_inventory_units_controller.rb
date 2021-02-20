class RentInventoryUnitsController < ApplicationController
  before_action :set_rent_inventory_unit, only: [:show, :edit, :update, :destroy]

  def index
    @rent_inventory_units = RentInventoryUnit.all
    respond_with(@rent_inventory_units)
  end

  def show
    respond_with(@rent_inventory_unit)
  end

  def new
    @rent_inventory_unit = RentInventoryUnit.new
    respond_with(@rent_inventory_unit)
  end

  def edit
  end

  def create
    @rent_inventory_unit = RentInventoryUnit.new(rent_inventory_unit_params)
    @rent_inventory_unit.save
    respond_with(@rent_inventory_unit)
  end

  def update
    @rent_inventory_unit.update(rent_inventory_unit_params)
    respond_with(@rent_inventory_unit)
  end

  def destroy
    @rent_inventory_unit.destroy
    respond_with(@rent_inventory_unit)
  end

  private
    def set_rent_inventory_unit
      @rent_inventory_unit = RentInventoryUnit.find(params[:id])
    end

    def rent_inventory_unit_params
      params[:rent_inventory_unit]
    end
end
