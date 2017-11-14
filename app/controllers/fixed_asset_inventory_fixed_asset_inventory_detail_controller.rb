class FixedAssetInventoryFixedAssetInventoryDetailController < ApplicationController
  load_and_authorize_resource :fixed_asset_inventory
  load_and_authorize_resource :fixed_asset_inventory_detail, through: :fixed_asset_inventory, parent: false

  def index
    # binding.pry
    @fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.order("fixed_asset_inventory_details.manage_unit_id, fixed_asset_inventory_details.unit_id, fixed_asset_inventory_details.asset_no")
    @fixed_asset_inventory_details_grid = initialize_grid(@fixed_asset_inventory_details,
      :name => 'fixed_asset_inventory_fixed_asset_inventory_details',
      :enable_export_to_csv => true,
      :csv_file_name => 'fixed_asset_inventory_details')

    export_grid_if_requested

  end

  def doing_index
    # binding.pry
    @fixed_asset_inventory_details = @fixed_asset_inventory.fixed_asset_inventory_details.where(manage_unit_id: current_user.unit_id).order("fixed_asset_inventory_details.unit_id, fixed_asset_inventory_details.asset_no")
    
    @fixed_asset_inventory_details_grid = initialize_grid(@fixed_asset_inventory_details,
      :name => 'fixed_asset_inventory_fixed_asset_inventory_details_doing',
      :enable_export_to_csv => true,
      :csv_file_name => 'fixed_asset_inventory_details')

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