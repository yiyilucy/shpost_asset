class FixedAssetInventoryFixedAssetInventoryDetailController < ApplicationController
  load_and_authorize_resource :fixed_asset_inventory
  load_and_authorize_resource :fixed_asset_inventory_detail, through: :fixed_asset_inventory, parent: false

  def index
    # binding.pry
    @from_sample = false

    if RailsEnv.is_oracle?
      @fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.joins("left join units on fixed_asset_inventory_details.unit_id = units.id").order("units.unit_level, fixed_asset_inventory_details.manage_unit_id, fixed_asset_inventory_details.unit_id, fixed_asset_inventory_details.asset_no")
    else
      @fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.joins("left join units as uunits on fixed_asset_inventory_details.unit_id = uunits.id").order("uunits.unit_level, fixed_asset_inventory_details.manage_unit_id, fixed_asset_inventory_details.unit_id, fixed_asset_inventory_details.asset_no")
    end
    @fixed_asset_inventory_details_grid = initialize_grid(@fixed_asset_inventory_details,
      :name => 'fixed_asset_inventory_fixed_asset_inventory_details',
      :enable_export_to_csv => true,
      :csv_file_name => 'fixed_asset_inventory_details')

    if !request.referer.blank? && (request.referer.include?"sample")
      @from_sample = true
    end

    export_grid_if_requested

  end

  def doing_index
    # binding.pry
    @from_sample = false

    if current_user.unit.unit_level == 2
      if RailsEnv.is_oracle?
        @fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.where(manage_unit_id: current_user.unit_id).joins("left join units on fixed_asset_inventory_details.unit_id = units.id").order("units.unit_level, fixed_asset_inventory_details.unit_id, fixed_asset_inventory_details.asset_no")
      else
        @fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.where(manage_unit_id: current_user.unit_id).joins("left join units as uunits on fixed_asset_inventory_details.unit_id = uunits.id").order("uunits.unit_level, fixed_asset_inventory_details.unit_id, fixed_asset_inventory_details.asset_no")
      end
    elsif current_user.unit.unit_level == 3
      child_ids = Unit.where(parent_id: current_user.unit_id).select(:id)
      if RailsEnv.is_oracle?
        @fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.where("fixed_asset_inventory_details.unit_id = ? or fixed_asset_inventory_details.unit_id in (?)", current_user.unit_id, child_ids).joins("left join units on fixed_asset_inventory_details.unit_id = units.id").order("units.unit_level, fixed_asset_inventory_details.unit_id, fixed_asset_inventory_details.asset_no")
      else
        @fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.where("fixed_asset_inventory_details.unit_id = ? or fixed_asset_inventory_details.unit_id in (?)", current_user.unit_id, child_ids).joins("left join units as uunits on fixed_asset_inventory_details.unit_id = uunits.id").order("uunits.unit_level, fixed_asset_inventory_details.unit_id, fixed_asset_inventory_details.asset_no")
      end
    elsif current_user.unit.unit_level == 4
      @fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.where("fixed_asset_inventory_details.unit_id = ?", current_user.unit_id).order("fixed_asset_inventory_details.asset_no")
    end
    
    @fixed_asset_inventory_details_grid = initialize_grid(@fixed_asset_inventory_details,
      :name => 'fixed_asset_inventory_fixed_asset_inventory_details_doing',
      :enable_export_to_csv => true,
      :csv_file_name => 'fixed_asset_inventory_details')

    if !request.referer.blank? && (request.referer.include?"sample")
      @from_sample = true
    end

    export_grid_if_requested

  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  

  

  private

  def set_relationship
    @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id])
  end

  def fixed_asset_inventory_detail_params
    params[:fixed_asset_inventory_detail]
  end

end