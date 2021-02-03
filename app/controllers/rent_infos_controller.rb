class RentInfosController < ApplicationController
  before_action :set_rent_info, only: [:show, :edit, :update, :destroy]

  def index
    catalog1 = nil

    if !params[:catalog].blank? && !params[:catalog][:fix_catalog1].blank?
      catalog1 = params[:catalog][:fix_catalog1]
    end

    @rent_infos = LowValueConsumptionInfo.get_in_use_infos(RentInfo, current_user, params[:fix_catalog4], params[:fix_catalog3], params[:fix_catalog2], catalog1)
    
    @rent_infos_grid = initialize_grid(@rent_infos,
      :name => 'rent_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'rent_infos', 
      :per_page => params[:page_size])
    export_grid_if_requested
  end

  def show
    respond_with(@rent_info)
  end

  def new
    @rent_info = RentInfo.new
    respond_with(@rent_info)
  end

  def edit
  end

  def create
    @rent_info = RentInfo.new(rent_info_params)
    @rent_info.save
    respond_with(@rent_info)
  end

  def update
    @rent_info.update(rent_info_params)
    respond_with(@rent_info)
  end

  def destroy
    @rent_info.destroy
    respond_with(@rent_info)
  end

  def select_catalog2
    @catalog2s = LowValueConsumptionInfo.select_catalog2(FixedAssetCatalog, params[:catalog1])
    
    respond_to do |format|
      format.js 
    end
  end

  def select_catalog3
   @catalog3s = LowValueConsumptionInfo.select_catalog3(FixedAssetCatalog, params[:catalog2])

    respond_to do |format|
      format.js 
    end
  end

  def select_catalog4
    @catalog4s = LowValueConsumptionInfo.select_catalog4(FixedAssetCatalog, params[:catalog3])

    respond_to do |format|
      format.js 
    end
  end

  private
    def set_rent_info
      @rent_info = RentInfo.find(params[:id])
    end

    def rent_info_params
      params[:rent_info]
    end
end
