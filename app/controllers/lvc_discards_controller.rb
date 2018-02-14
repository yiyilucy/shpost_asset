class LvcDiscardsController < ApplicationController
  before_action :set_lvc_discard, only: [:show, :edit, :update, :destroy]

  def index
    @lvc_discards = nil
    if current_user.deviceadmin?
      @lvc_discards = LvcDiscard.accessible_by(current_ability).where("create_user_id = ? or create_unit_id = ?", current_user.id, current_user.unit_id)
    elsif current_user.accountant?
      @lvc_discards = LvcDiscard.accessible_by(current_ability).where("(create_unit_id = ? and status = ?) or checked_user_id = ?", current_user.unit_id, "checking", current_user.id)
    end
    
    @lvc_discards_grid = initialize_grid(@lvc_discards, order: 'lvc_discards.created_at',
      order_direction: 'desc')
  end

  def show
    respond_with(@lvc_discard)
  end

  def new
    @lvc_discard = LvcDiscard.new
    respond_with(@lvc_discard)
  end

  def edit
  end

  def create
    @lvc_discard = LvcDiscard.new(lvc_discard_params)
    @lvc_discard.save
    respond_with(@lvc_discard)
  end

  def update
    @lvc_discard.update(lvc_discard_params)
    respond_with(@lvc_discard)
  end

  def destroy
    @lvc_discard.destroy
    respond_with(@lvc_discard)
  end

  def approve
    ActiveRecord::Base.transaction do 
      if !params.blank? and !params[:id].blank?
        @lvc_discard = LvcDiscard.find(params[:id].to_i)
        @lvc_discard.update status: "done", checked_user_id: current_user.id
        @lvc_discard.lvc_discard_details.each do |l|
          l.low_value_consumption_info.update status: "discard", discard_at: Time.now, log: (l.low_value_consumption_info.log.blank? ? "" : l.low_value_consumption_info.log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + User.find(@lvc_discard.create_user_id).name + " " +"低值易耗品信息报废" + ","
        end

        respond_to do |format|
          format.html { redirect_to lvc_discards_url, notice: I18n.t('controller.approve_success_notice', model: '低值易耗品报废单') }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to lvc_discards_url, notice: '找不到该报废单' }
          format.json { head :no_content }
        end
      end
    end
  end

  def decline
    # binding.pry
    ActiveRecord::Base.transaction do 
      if !params.blank? and !params[:id].blank?
        @lvc_discard = LvcDiscard.find(params[:id].to_i)
        @lvc_discard.update status: "declined", checked_user_id: current_user.id

        respond_to do |format|
          format.html { redirect_to lvc_discards_url, notice: I18n.t('controller.decline_success_notice', model: '低值易耗品报废单') }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to lvc_discards_url, notice: '找不到该报废单' }
          format.json { head :no_content }
        end
      end
    end
    
  end

  

  private
    def set_lvc_discard
      @lvc_discard = LvcDiscard.find(params[:id])
    end

    def lvc_discard_params
      params[:lvc_discard]
    end
end
