class PurchaseRentInfoController < ApplicationController
  load_and_authorize_resource :purchase
  load_and_authorize_resource :rent_info, through: :purchase, parent: false

  def index
    # binding.pry
    @rent_infos = @rent_infos.order(:use_unit_id, :fixed_asset_catalog_id)
    @rent_infos_grid = initialize_grid(@rent_infos,
      :per_page => params[:page_size],
      :name => 'purchase_rent_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'rent_infos')

    export_grid_if_requested

  end

  def show
  end

  def new
  end

  def to_string(text)
    if text.is_a? Float
      return text.to_s.split('.0')[0]
    else
      return text
    end
  end  

  def edit
    if !@rent_info.relevant_unit_id.blank?
      @relename = Unit.get_relevant_unit_name(@rent_info.relevant_unit_id)
    else
      @relename = ''
    end
    if !@rent_info.use_unit_id.blank?
      @usename = Unit.get_use_unit_name(@rent_info.use_unit_id)
    else
      @usename = ''
    end
    @fixed_asset_catalog = FixedAssetCatalog.get_catalog_name(@rent_info.fixed_asset_catalog_id)
  end

  def create
    ActiveRecord::Base.transaction do 
      success = false
      notice = ""
      
      if params["rent_info"].blank? or params["rent_info"]["fixed_asset_catalog_id"].blank?
        notice = "类别目录不能为空" 
      elsif params["rent_info"].blank? or params["rent_info"]["asset_name"].blank?
        notice = "资产名称不能为空" 
      elsif params["rent_info"].blank? or params["rent_info"]["brand_model"].blank?
        notice = "结构/型号不能为空" 
      elsif params["rent_info"].blank? or params["rent_info"]["use_unit_id"].blank?
        notice = "使用部门不能为空" 
      elsif params["rent_info"].blank? or params["rent_info"]["location"].blank?
        notice = "地点备注不能为空"
      elsif params["rent_info"].blank? or params["rent_info"]["sum"].blank?
        notice = "租金总金额不能为空"
      elsif params["rent_info"].blank? or params["rent_info"]["use_right_start"].blank?
        notice = "使用权取得日期不能为空"
      elsif params["rent_info"].blank? or params["rent_info"]["use_right_end"].blank?
        notice = "使用权终止日期不能为空"
      elsif params["rent_info"].blank? or params["rent_info"]["pay_cycle"].blank?
        notice = "租赁费支付周期不能为空"
      elsif params["rent_info"].blank? or params["rent_info"]["deposit"].blank?
        notice = "租赁押金不能为空"
      elsif params["rent_info"].blank? or params["rent_info"]["relevant_unit_id"].blank?
        notice = "归口管理部门不能为空"          
      elsif params[:amount].blank? or params[:amount][:amount].blank? or params[:amount][:amount].to_i <= 0
        notice = I18n.t('controller.purchase_low_value_consumption_info_no_amount_notice', model: '其他租赁资产信息')
      else
        catalog = FixedAssetCatalog.find(params["rent_info"]["fixed_asset_catalog_id"])
        if !catalog.blank? && catalog.is_house? && (params["rent_info"].blank? or params["rent_info"]["area"].blank?)
          notice = "建筑面积（平方米）不能为空" 
        elsif !catalog.blank? && catalog.is_car? && (params["rent_info"].blank? or params["rent_info"]["license"].blank?)
          notice = "牌照不能为空"      
        end
      end

      if notice.blank?
        amount = params[:amount][:amount].to_i
        while amount>0 do 
          # binding.pry
          RentInfo.create!(fixed_asset_catalog_id: params[:rent_info][:fixed_asset_catalog_id], 
            asset_name: params[:rent_info][:asset_name], 
            use_at: params[:rent_info][:use_at], 
            amount: 1, 
            brand_model: params[:rent_info][:brand_model], 
            use_user: params[:rent_info][:use_user], 
            use_unit_id: params[:rent_info][:use_unit_id],
            location: params[:rent_info][:location],
            area: params[:rent_info][:area], 
            sum: params[:rent_info][:sum], 
            use_right_start: params[:rent_info][:use_right_start], 
            use_right_end: params[:rent_info][:use_right_end], 
            pay_cycle: params[:rent_info][:pay_cycle],
            license: params[:rent_info][:license], 
            deposit: params[:rent_info][:deposit],
            relevant_unit_id: params[:rent_info][:relevant_unit_id], 
            status: "waiting", 
            print_times: 0, 
            purchase_id: @purchase.id, 
            manage_unit_id: @purchase.manage_unit_id,
            desc: params[:rent_info][:desc],
            change_log: params[:rent_info][:change_log], 
            )
          
          amount = amount-1
        end
        success = true

        respond_to do |format|   
          if success           
            format.html { redirect_to purchase_rent_infos_path(@purchase), notice: I18n.t('controller.create_success_notice', model: '其他租赁资产信息')}
            format.json { head :no_content }
          else
            format.html { render action: 'new' }
            format.json { render json: @rent_info.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to new_purchase_rent_info_url, notice: notice }
          format.json { head :no_content }
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @rent_info.update(rent_info_params)
        format.html { redirect_to purchase_rent_info_path(@purchase,@rent_info), notice: I18n.t('controller.update_success_notice', model: '其他租赁资产信息')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @rent_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @rent_info.destroy
    respond_to do |format|
      format.html { redirect_to purchase_rent_infos_path(@purchase) }
      format.json { head :no_content }
    end
  end

  private

  def set_relationship
    @rent_info = RentInfo.find(params[:id])
  end

  def rent_info_params
    params.require(:rent_info).permit(:asset_name, :asset_no, :fixed_asset_catalog_id, :use_at, :amount, :brand_model, :use_user, :use_unit_id, :location, :area, :sum, :use_right_start, :use_right_end, :pay_cycle, :license, :deposit, :relevant_unit_id, :manage_unit_id, :desc, :is_rent, :is_reprint, :change_log)
  end

end