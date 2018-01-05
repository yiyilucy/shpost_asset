class LowValueConsumptionInventoryLowValueConsumptionInventoryDetailController < ApplicationController
  load_and_authorize_resource :low_value_consumption_inventory
  load_and_authorize_resource :low_value_consumption_inventory_detail, through: :low_value_consumption_inventory, parent: false

  def index
    # binding.pry
    if RailsEnv.is_oracle?
      @low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.joins("left join units on lvc_inventory_details.use_unit_id = units.id").order("units.unit_level, lvc_inventory_details.manage_unit_id, lvc_inventory_details.use_unit_id, lvc_inventory_details.asset_no")
    else
      @low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.joins("left join units as uunits on lvc_inventory_details.use_unit_id = uunits.id").order("uunits.unit_level, lvc_inventory_details.manage_unit_id, lvc_inventory_details.use_unit_id, lvc_inventory_details.asset_no")
    end

    @low_value_consumption_inventory_details_grid = initialize_grid(@low_value_consumption_inventory_details,
      :name => 'low_value_consumption_inventory_low_value_consumption_inventory_details',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_inventory_details')

    export_grid_if_requested

  end

  def doing_index
    # binding.pry
    if current_user.unit.unit_level == 2
      if RailsEnv.is_oracle?
        @low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.where(manage_unit_id: current_user.unit_id).joins("left join units on lvc_inventory_details.use_unit_id = units.id").order("units.unit_level, lvc_inventory_details.use_unit_id, lvc_inventory_details.asset_no")
      else
        @low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.where(manage_unit_id: current_user.unit_id).joins("left join units as uunits on lvc_inventory_details.use_unit_id = uunits.id").order("uunits.unit_level, lvc_inventory_details.use_unit_id, lvc_inventory_details.asset_no")
      end
    elsif current_user.unit.unit_level == 3 and !current_user.unit.is_facility_management_unit
      # binding.pry
      child_ids = Unit.where(parent_id: current_user.unit_id).select(:id)
      if RailsEnv.is_oracle?
        @low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.where("lvc_inventory_details.use_unit_id = ? or lvc_inventory_details.use_unit_id in (?)", current_user.unit_id, child_ids).joins("left join units on lvc_inventory_details.use_unit_id = units.id").order("units.unit_level, lvc_inventory_details.use_unit_id, lvc_inventory_details.asset_no")
      else
        @low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.where("lvc_inventory_details.use_unit_id = ? or lvc_inventory_details.use_unit_id in (?)", current_user.unit_id, child_ids).joins("left join units as uunits on lvc_inventory_details.use_unit_id = uunits.id").order("uunits.unit_level, lvc_inventory_details.use_unit_id, lvc_inventory_details.asset_no")
      end
    end
    
    @low_value_consumption_inventory_details_grid = initialize_grid(@low_value_consumption_inventory_details,
      :name => 'low_value_consumption_inventory_low_value_consumption_inventory_details_doing',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_inventory_details')

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