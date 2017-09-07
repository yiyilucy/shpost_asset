class LowValueConsumptionInfosController < ApplicationController
  before_action :set_low_value_consumption_info, only: [:show, :edit, :update, :destroy]

  def index
    @low_value_consumption_infos = LowValueConsumptionInfo.all
    respond_with(@low_value_consumption_infos)
  end

  def show
    respond_with(@low_value_consumption_info)
  end

  def new
    @low_value_consumption_info = LowValueConsumptionInfo.new
    respond_with(@low_value_consumption_info)
  end

  def edit
  end

  def create
    @low_value_consumption_info = LowValueConsumptionInfo.new(low_value_consumption_info_params)
    @low_value_consumption_info.save
    respond_with(@low_value_consumption_info)
  end

  def update
    @low_value_consumption_info.update(low_value_consumption_info_params)
    respond_with(@low_value_consumption_info)
  end

  def destroy
    @low_value_consumption_info.destroy
    respond_with(@low_value_consumption_info)
  end

  private
    def set_low_value_consumption_info
      @low_value_consumption_info = LowValueConsumptionInfo.find(params[:id])
    end

    def low_value_consumption_info_params
      params[:low_value_consumption_info]
    end
end
