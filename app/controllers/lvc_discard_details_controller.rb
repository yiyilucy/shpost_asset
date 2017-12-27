class LvcDiscardDetailsController < ApplicationController
  before_action :set_lvc_discard_detail, only: [:show, :edit, :update, :destroy]

  def index
    @lvc_discard_details = LvcDiscardDetail.all
    respond_with(@lvc_discard_details)
  end

  def show
    respond_with(@lvc_discard_detail)
  end

  def new
    @lvc_discard_detail = LvcDiscardDetail.new
    respond_with(@lvc_discard_detail)
  end

  def edit
  end

  def create
    @lvc_discard_detail = LvcDiscardDetail.new(lvc_discard_detail_params)
    @lvc_discard_detail.save
    respond_with(@lvc_discard_detail)
  end

  def update
    @lvc_discard_detail.update(lvc_discard_detail_params)
    respond_with(@lvc_discard_detail)
  end

  def destroy
    @lvc_discard_detail.destroy
    respond_with(@lvc_discard_detail)
  end

  private
    def set_lvc_discard_detail
      @lvc_discard_detail = LvcDiscardDetail.find(params[:id])
    end

    def lvc_discard_detail_params
      params[:lvc_discard_detail]
    end
end
