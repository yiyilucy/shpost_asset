class FixedAssetInventoryUnitsController < ApplicationController
  before_action :set_fixed_asset_inventory_unit, only: [:show, :edit, :update, :destroy]

  def index
    @fixed_asset_inventory_units = FixedAssetInventoryUnit.all
    respond_with(@fixed_asset_inventory_units)
  end

  def show
    respond_with(@fixed_asset_inventory_unit)
  end

  def new
    @fixed_asset_inventory_unit = FixedAssetInventoryUnit.new
    respond_with(@fixed_asset_inventory_unit)
  end

  def edit
  end

  def create
    @fixed_asset_inventory_unit = FixedAssetInventoryUnit.new(fixed_asset_inventory_unit_params)
    @fixed_asset_inventory_unit.save
    respond_with(@fixed_asset_inventory_unit)
  end

  def update
    @fixed_asset_inventory_unit.update(fixed_asset_inventory_unit_params)
    respond_with(@fixed_asset_inventory_unit)
  end

  def destroy
    @fixed_asset_inventory_unit.destroy
    respond_with(@fixed_asset_inventory_unit)
  end

  private
    def set_fixed_asset_inventory_unit
      @fixed_asset_inventory_unit = FixedAssetInventoryUnit.find(params[:id])
    end

    def fixed_asset_inventory_unit_params
      params[:fixed_asset_inventory_unit]
    end
end
