class LowValueConsumptionInventoryLowValueConsumptionInventoryDetailController < ApplicationController
  load_and_authorize_resource :low_value_consumption_inventory
  load_and_authorize_resource :low_value_consumption_inventory_detail, through: :low_value_consumption_inventory, parent: false

  def index
    # binding.pry
    @low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.order("lvc_inventory_details.manage_unit_id, lvc_inventory_details.use_unit_id, lvc_inventory_details.asset_no")
    @low_value_consumption_inventory_details_grid = initialize_grid(@low_value_consumption_inventory_details,
      :name => 'low_value_consumption_inventory_low_value_consumption_inventory_details',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_inventory_details')

    export_grid_if_requested

  end

  def doing_index
    # binding.pry
    @low_value_consumption_inventory_details = @low_value_consumption_inventory.low_value_consumption_inventory_details.where(manage_unit_id: current_user.unit_id).order("lvc_inventory_details.use_unit_id, lvc_inventory_details.asset_no")
    
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