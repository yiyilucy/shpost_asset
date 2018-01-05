class PurchaseLowValueConsumptionInfoController < ApplicationController
  load_and_authorize_resource :purchase
  load_and_authorize_resource :low_value_consumption_info, through: :purchase, parent: false

  def index
    # binding.pry
    @low_value_consumption_infos_grid = initialize_grid(@low_value_consumption_infos,
      :order => 'low_value_consumption_infos.asset_no',
      :order_direction => 'asc', per_page: 50,
      :name => 'purchase_low_value_consumption_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_infos')

    export_grid_if_requested

  end

  def show
  end

  def new
  end

  def edit
    if !@low_value_consumption_info.relevant_unit_id.blank?
      @relename = Unit.find_by(id: @low_value_consumption_info.relevant_unit_id).try(:name)
    else
      @relename = ''
    end
    if !@low_value_consumption_info.use_unit_id.blank?
      @usename = Unit.find_by(id: @low_value_consumption_info.use_unit_id).try(:name)
    else
      @usename = ''
    end
    @low_value_consumption_catalog = LowValueConsumptionCatalog.find_by(id: @low_value_consumption_info.lvc_catalog_id).try(:name)
  end

  def batch_edit
    @relename = ''
    @usename = ''
    @low_value_consumption_catalog = ''
    @lvcids = ""
# binding.pry
 
    if !params["purchase_low_value_consumption_infos"].blank? and !params["purchase_low_value_consumption_infos"]["selected"].blank?
      @lvcids = params["purchase_low_value_consumption_infos"]["selected"].compact.join(",")
      @low_value_consumption_info = LowValueConsumptionInfo.find(params["purchase_low_value_consumption_infos"]["selected"].first.to_i)
    
      if !@low_value_consumption_info.relevant_unit_id.blank?
        @relename = Unit.find_by(id: @low_value_consumption_info.relevant_unit_id).try(:name)
      end
      if !@low_value_consumption_info.use_unit_id.blank?
        @usename = Unit.find_by(id: @low_value_consumption_info.use_unit_id).try(:name)
      end
      @low_value_consumption_catalog = LowValueConsumptionCatalog.find_by(id: @low_value_consumption_info.lvc_catalog_id).try(:name)
    else
      respond_to do |format|
          format.html { redirect_to purchase_low_value_consumption_infos_url, alert: "请勾选低值易耗品" }
          format.json { head :no_content }
      end
    end
  end

  def create
    ActiveRecord::Base.transaction do 
      success = false
      notice = ""
      # binding.pry
      if params["low_value_consumption_info"].blank? or params["low_value_consumption_info"]["lvc_catalog_id"].blank?
        notice = "类别目录不能为空" 
      elsif params["low_value_consumption_info"].blank? or params["low_value_consumption_info"]["asset_name"].blank?
        notice = "资产名称不能为空" 
      elsif params["low_value_consumption_info"].blank? or params["low_value_consumption_info"]["brand_model"].blank?
        notice = "品牌型号不能为空" 
      elsif params["low_value_consumption_info"].blank? or params["low_value_consumption_info"]["sum"].blank?
        notice = "金额不能为空" 
      elsif params["low_value_consumption_info"].blank? or params["low_value_consumption_info"]["buy_at"].blank?
        notice = "购买日期不能为空"
      elsif params["low_value_consumption_info"].blank? or params["low_value_consumption_info"]["relevant_unit_id"].blank?
        notice = "归口管理部门不能为空"          
      elsif params[:amount].blank? or params[:amount][:amount].blank? or params[:amount][:amount].to_i <= 0
        notice = I18n.t('controller.purchase_low_value_consumption_info_no_amount_notice', model: '低值易耗品信息')
      end

      if notice.blank?
        amount = params[:amount][:amount].to_i
        while amount>0 do 
          # binding.pry
          LowValueConsumptionInfo.create!(sn: params[:low_value_consumption_info][:sn], 
            lvc_catalog_id: params[:low_value_consumption_info][:lvc_catalog_id], 
            asset_name: params[:low_value_consumption_info][:asset_name], 
            batch_no: params[:low_value_consumption_info][:batch_no], 
            brand_model: params[:low_value_consumption_info][:brand_model], 
            measurement_unit: params[:low_value_consumption_info][:measurement_unit], 
            sum: params[:low_value_consumption_info][:sum], 
            buy_at: params[:low_value_consumption_info][:buy_at], 
            branch: params[:low_value_consumption_info][:branch],
            location: params[:low_value_consumption_info][:location], 
            user: params[:low_value_consumption_info][:user], 
            relevant_unit_id: params[:low_value_consumption_info][:relevant_unit_id], 
            use_unit_id: params[:low_value_consumption_info][:use_unit_id], 
            change_log: params[:low_value_consumption_info][:change_log], 
            purchase_id: @purchase.id, 
            status: "waiting", 
            print_times: 0, 
            manage_unit_id: @purchase.manage_unit_id)
          
          amount = amount-1
        end
        success = true

        respond_to do |format|   
          if success           
            format.html { redirect_to purchase_low_value_consumption_infos_path(@purchase), notice: I18n.t('controller.create_success_notice', model: '低值易耗品信息')}
            format.json { head :no_content }
          else
            format.html { render action: 'new' }
            format.json { render json: @low_value_consumption_info.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to new_purchase_low_value_consumption_info_url, notice: notice }
          format.json { head :no_content }
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @low_value_consumption_info.update(low_value_consumption_info_params)
        format.html { redirect_to purchase_low_value_consumption_info_path(@purchase,@low_value_consumption_info), notice: I18n.t('controller.update_success_notice', model: '低值易耗品信息')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @low_value_consumption_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @low_value_consumption_info.destroy
    respond_to do |format|
      format.html { redirect_to purchase_low_value_consumption_infos_path(@purchase) }
      format.json { head :no_content }
    end
  end

  def batch_destroy
    # binding.pry
    ActiveRecord::Base.transaction do
      if !params["purchase_low_value_consumption_infos"].blank? and !params["purchase_low_value_consumption_infos"]["selected"].blank?
        params["purchase_low_value_consumption_infos"]["selected"].each do |id|
          LowValueConsumptionInfo.find(id.to_i).destroy
        end
        flash[:notice] = "批量删除成功"
      end
    end
    redirect_to purchase_low_value_consumption_infos_path(@purchase)
  end

  def batch_update
    ActiveRecord::Base.transaction do
      # binding.pry
      if !params[:lvcids].blank?
        params[:lvcids].split(",").map(&:to_i).each do |id|
          @low_value_consumption_info = LowValueConsumptionInfo.find_by(id:id.to_i)
          if (["waiting", "declined"].include?@purchase.status and !@purchase.is_send) or @purchase.status.eql?"revoked"
            @low_value_consumption_info.sn = params[:sn]
            @low_value_consumption_info.lvc_catalog_id = params[:low_value_consumption_info][:lvc_catalog_id]
            @low_value_consumption_info.asset_name = params[:asset_name]
            @low_value_consumption_info.batch_no = params[:batch_no]
            @low_value_consumption_info.brand_model = params[:brand_model]
            @low_value_consumption_info.measurement_unit = params[:measurement_unit]
            @low_value_consumption_info.sum = params[:sum]           
            @low_value_consumption_info.change_log = params[:change_log]
            @low_value_consumption_info.use_years = params[:use_years]
          end
          @low_value_consumption_info.branch = params[:branch]
          @low_value_consumption_info.location = params[:location]
          @low_value_consumption_info.user = params[:user]
          @low_value_consumption_info.relevant_unit_id = params[:low_value_consumption_info][:relevant_unit_id]
          @low_value_consumption_info.use_unit_id = params[:low_value_consumption_info][:use_unit_id]
          @low_value_consumption_info.desc1 = params[:desc1]
          @low_value_consumption_info.save
        end
        flash[:notice] = "批量修改成功"
        redirect_to purchase_low_value_consumption_infos_path(@purchase)
      else
        flash[:alert] = "请勾选低值易耗品"
        redirect_to purchase_low_value_consumption_infos_path(@purchase)
      end
    end
  end

  def print
    if params[:purchase_low_value_consumption_infos] && params[:purchase_low_value_consumption_infos][:selected]
      @selected = params[:purchase_low_value_consumption_infos][:selected]
    else
      flash[:alert] = "请勾选需要打印的低值易耗品"
      respond_to do |format|
        format.html { redirect_to purchase_low_value_consumption_infos_path(@purchase) }
        format.json { head :no_content }
      end
    end

    # binding.pry
  end


  private

  def set_relationship
    @low_value_consumption_info = LowValueConsumptionInfo.find(params[:id])
  end

  def low_value_consumption_info_params
    params.require(:low_value_consumption_info).permit(:asset_name, :lvc_catalog_id, :relevant_unit_id, :buy_at, :measurement_unit, :sum, :use_unit_id, :branch, :location, :user, :brand_model, :batch_no, :manage_unit_id, :use_years, :desc1)
  end

end