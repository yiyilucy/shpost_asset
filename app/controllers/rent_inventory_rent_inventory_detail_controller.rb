class RentInventoryRentInventoryDetailController < ApplicationController
  load_and_authorize_resource :rent_inventory
  load_and_authorize_resource :rent_inventory_detail, through: :rent_inventory, parent: false

  def index
    if RailsEnv.is_oracle?
      @rent_inventory_details = @rent_inventory.rent_inventory_details.joins("left join units on rent_inventory_details.use_unit_id = units.id").order("units.unit_level, rent_inventory_details.manage_unit_id, rent_inventory_details.use_unit_id, rent_inventory_details.asset_no")
    else
      @rent_inventory_details = @rent_inventory.rent_inventory_details.joins("left join units as uunits on rent_inventory_details.use_unit_id = uunits.id").order("uunits.unit_level, rent_inventory_details.manage_unit_id, rent_inventory_details.use_unit_id, rent_inventory_details.asset_no")
    end

    @rent_inventory_details_grid = initialize_grid(@rent_inventory_details,
      :name => 'rent_inventory_rent_inventory_details',
      :enable_export_to_csv => true,
      :csv_file_name => 'rent_inventory_details')

    export_grid_if_requested

  end

  def doing_index
    if current_user.unit.unit_level == 2
      if RailsEnv.is_oracle?
        @rent_inventory_details = @rent_inventory.rent_inventory_details.where(manage_unit_id: current_user.unit_id).joins("left join units on rent_inventory_details.use_unit_id = units.id").order("units.unit_level, rent_inventory_details.use_unit_id, rent_inventory_details.asset_no")
      else
        @rent_inventory_details = @rent_inventory.rent_inventory_details.where(manage_unit_id: current_user.unit_id).joins("left join units as uunits on rent_inventory_details.use_unit_id = uunits.id").order("uunits.unit_level, rent_inventory_details.use_unit_id, rent_inventory_details.asset_no")
      end
    elsif current_user.unit.unit_level == 3
      child_ids = Unit.where(parent_id: current_user.unit_id).select(:id)
      if RailsEnv.is_oracle?
        @rent_inventory_details = @rent_inventory.rent_inventory_details.where("rent_inventory_details.use_unit_id = ? or rent_inventory_details.use_unit_id in (?)", current_user.unit_id, child_ids).joins("left join units on rent_inventory_details.use_unit_id = units.id").order("units.unit_level, rent_inventory_details.use_unit_id, rent_inventory_details.asset_no")
      else
        @rent_inventory_details = @rent_inventory.rent_inventory_details.where("rent_inventory_details.use_unit_id = ? or rent_inventory_details.use_unit_id in (?)", current_user.unit_id, child_ids).joins("left join units as uunits on rent_inventory_details.use_unit_id = uunits.id").order("uunits.unit_level, rent_inventory_details.use_unit_id, rent_inventory_details.asset_no")
      end
    elsif current_user.unit.unit_level == 4
      @rent_inventory_details = @rent_inventory.rent_inventory_details.where("rent_inventory_details.use_unit_id = ?", current_user.unit_id).order("rent_inventory_details.asset_no")
    end
    
    @rent_inventory_details_grid = initialize_grid(@rent_inventory_details,
      :name => 'rent_inventory_rent_inventory_details_doing',
      :enable_export_to_csv => true,
      :csv_file_name => 'rent_inventory_details')

    export_grid_if_requested

  end

  end