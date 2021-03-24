class PurchasesController < ApplicationController
  load_and_authorize_resource

  def index
    @atype = params[:atype]

    if current_user.deviceadmin?
      @purchases = @purchases.accessible_by(current_ability).where("(create_user_id = ? or create_unit_id = ?) and status = ? and is_send = ? and atype = ?", current_user.id, current_user.unit_id, "waiting", false, @atype)
    end

    @purchases_grid = initialize_grid(@purchases, order: 'purchases.created_at',
      order_direction: 'desc')
  end

  def to_do_index
    @atype = params[:atype]

    if current_user.deviceadmin?
      @purchases = @purchases.accessible_by(current_ability).where("((manage_unit_id = ? and status in (?) and is_send = ? ) or ((create_user_id = ? or create_unit_id = ?) and status in (?)) or ((create_user_id = ? or create_unit_id = ?) and status = ? and is_send = ?)) and atype = ?", current_user.unit_id, ["waiting", "declined"], true, current_user.id, current_user.unit_id, ["declined", "revoked"], current_user.id, current_user.unit_id, "waiting", true, @atype )
    elsif current_user.accountant?
      @purchases = @purchases.accessible_by(current_ability).where(manage_unit_id: current_user.unit_id, status: "checking", atype: @atype)
    end

    @purchases_grid = initialize_grid(@purchases, order: 'purchases.updated_at', order_direction: 'desc')
  end

  def doing_index
    @atype = params[:atype]
    
    if current_user.accountant?
      @purchases = @purchases.accessible_by(current_ability).where("((manage_unit_id = ? and status in (?) and is_send = ? ) or (create_unit_id = ? and status in (?)) or (create_unit_id = ? and status = ? and is_send = ?)) and atype = ?", current_user.unit_id, ["waiting", "declined"], true, current_user.unit_id, ["declined", "revoked"], current_user.unit_id, "waiting", true, @atype )
    elsif current_user.deviceadmin?
      @purchases = @purchases.accessible_by(current_ability).where("(manage_unit_id = ? or create_unit_id = ? or create_user_id = ?) and status = ? and atype = ?", current_user.unit_id, current_user.unit_id, current_user.id, "checking", @atype)
    end

    @purchases_grid = initialize_grid(@purchases, order: 'purchases.updated_at', order_direction: 'desc')
  end

  def done_index
    @atype = params[:atype]
    
    if current_user.deviceadmin?
      @purchases = @purchases.accessible_by(current_ability).where("(manage_unit_id = ? or create_unit_id = ? or create_user_id = ?) and status in (?) and atype = ?", current_user.unit_id, current_user.unit_id, current_user.id, ["canceled", "done"], @atype)
    elsif current_user.accountant?
      @purchases = @purchases.accessible_by(current_ability).where("manage_unit_id = ? and status in (?) and atype = ?", current_user.unit_id, ["canceled", "done"], @atype)
    end
    
    @purchases_grid = initialize_grid(@purchases, order: 'purchases.updated_at', order_direction: 'desc')
  end

  def show
  end

  def new
    @atype = params[:atype]
  end

  def edit
    @atype = params[:atype]
    @source = params[:source]
    @usename = Unit.find_by(id: @purchase.use_unit_id).try(:name)
  end

  def create
    if !params[:purchase].blank? and !params[:purchase][:no].blank?
      ori_purchase = Purchase.find_by(no: params[:purchase][:no])
      if !ori_purchase.blank?
        # raise "采购单号已存在"
        respond_to do |format|
          format.html { redirect_to new_purchase_url, notice: I18n.t('controller.purchase_exist_no_notice', model: (ori_purchase.atype.eql?"lvc") ? '采购单' : '其他租赁资产') }
          format.json { head :no_content }
        end
      else
        ActiveRecord::Base.transaction do 
          @purchase.create_user_id = current_user.id
          @purchase.create_unit_id = current_user.try(:unit).try :id
          @purchase.status = "waiting"
          @purchase.manage_unit_id = current_user.try(:unit).try :id
          @purchase.change_log = Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"#{(params[:atype].eql?'lvc') ? '采购单' : '其他租赁资产'}创建" + ","
          @purchase.atype = params[:atype]

          respond_to do |format|
            if @purchase.save
              # amount = @purchase.amount
              # while amount>0 do 
                # LowValueConsumptionInfo.create!(lvc_catalog_id: params[:purchase][:lvc_catalog_id], 
                #   asset_name: params[:purchase][:asset_name], 
                #   brand_model: params[:purchase][:brand_model], 
                #   measurement_unit: params[:purchase][:measurement_unit], 
                #   sum: params[:purchase][:sum], 
                #   relevant_unit_id: params[:purchase][:relevant_unit_id], 
                #   buy_at: params[:purchase][:buy_at], 
                #   use_unit_id: params[:purchase][:use_unit_id], 
                #   branch: params[:purchase][:branch], 
                #   batch_no: params[:purchase][:batch_no], 
                #   purchase_id: @purchase.id, 
                #   status: "waiting", 
                #   print_times: 0, 
                #   manage_unit_id: @purchase.manage_unit_id)
              #   amount = amount-1
              # end

              format.html { redirect_to purchases_path(atype: params[:atype]), notice: I18n.t('controller.create_success_notice', model: (params[:atype].eql?"lvc") ? '采购单' : '其他租赁资产') }
              format.json { render action: 'show', status: :created, location: @purchase }
            else
              format.html { render action: 'new' }
              format.json { render json: @purchase.errors, status: :unprocessable_entity }
            end
          end
        end
      end
    end
  end

  def update
    ActiveRecord::Base.transaction do
      respond_to do |format|
        if @purchase.update(purchase_params)
          @purchase.update change_log:  (@purchase.change_log.blank? ? "" : @purchase.change_log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}修改" + ","
        
          # amount = @purchase.amount
          # @purchase.low_value_consumption_infos.each do |info| 
          #   if @purchase.is_send
          #     info.update!(relevant_unit_id: params[:purchase][:relevant_unit_id], use_unit_id: params[:purchase][:use_unit_id])
          #   else
          #     info.update(lvc_catalog_id: params[:purchase][:lvc_catalog_id], asset_name: params[:purchase][:asset_name], brand_model: params[:purchase][:brand_model], measurement_unit: params[:purchase][:measurement_unit], sum: params[:purchase][:sum], relevant_unit_id: params[:purchase][:relevant_unit_id], buy_at: params[:purchase][:buy_at], use_unit_id: params[:purchase][:use_unit_id], branch: params[:purchase][:branch], batch_no: params[:purchase][:batch_no])
          #   end

          # end

          if @purchase.is_send || (params[:source].eql?"to_do")
            format.html { redirect_to to_do_index_purchases_url(atype: params[:atype]), notice: I18n.t('controller.update_success_notice', model: "#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}")  }
            format.json { head :no_content }
          else
            format.html { redirect_to purchases_path(atype: params[:atype]), notice: I18n.t('controller.update_success_notice', model: "#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}")  }
            format.json { head :no_content }
          end
        else
          format.html { render action: 'edit' }
          format.json { render json: @purchase.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @purchase.destroy
    @purchase.low_value_consumption_infos.delete_all
    respond_to do |format|
      format.html { redirect_to request.referer }
      format.json { head :no_content }
    end
  end

  def to_send
  end

  def do_send
    if !params[:current_pid].blank? and !params[:purchase].blank? and !params[:purchase][:use_unit_id].blank?
      @purchase = Purchase.find(params[:current_pid].to_i)
      @purchase.manage_unit_id = params[:purchase][:use_unit_id]
      @purchase.is_send = true
      @purchase.status = "waiting"
      @purchase.change_log = (@purchase.change_log.blank? ? "" : @purchase.change_log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"采购单下发" + ","
      @purchase.save

      @purchase.low_value_consumption_infos.update_all manage_unit_id: @purchase.manage_unit_id, status: "waiting"
      
      respond_to do |format|
        format.html { redirect_to purchases_url, notice: I18n.t('controller.send_success_notice', model: "采购单") }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to purchases_url }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  def to_check
    ActiveRecord::Base.transaction do 
      @atype = params[:atype]
      if (!@atype.blank? && (@atype.eql?"lvc") && @purchase.can_to_check?) || (!@atype.blank? && (@atype.eql?"rent") && @purchase.can_to_check_rent?)
        @purchase.status = "checking"
        @purchase.to_check_user_id = current_user.id
        @purchase.change_log = (@purchase.change_log.blank? ? "" : @purchase.change_log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}送审" + ","

        respond_to do |format|
          if @purchase.save
            if @atype.eql?"lvc"
              @purchase.low_value_consumption_infos.update_all(status: "checking")
            elsif @atype.eql?"rent"
              @purchase.rent_infos.update_all(status: "checking")
            end
            if (@purchase.create_user_id == current_user.id) && (params[:source].eql?"index")
              format.html { redirect_to purchases_url(atype: @atype), notice: I18n.t('controller.to_check_success_notice', model: "#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}") }
              format.json { head :no_content }
            else
              format.html { redirect_to to_do_index_purchases_url(atype: @atype), notice: I18n.t('controller.to_check_success_notice', model: "#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}") }
              format.json { head :no_content }
            end
          else
            if (@purchase.create_user_id == current_user.id) && (params[:source].eql?"index")
              format.html { redirect_to purchases_url(atype: @atype) }
              format.json { render json: @purchase.errors, status: :unprocessable_entity }
            else
              format.html { redirect_to to_do_index_purchases_url(atype: @atype) }
              format.json { render json: @purchase.errors, status: :unprocessable_entity }
            end
          end
        end
      else
        if @atype.eql?"lvc"
          flash[:alert] = "低值易耗品不能为空,所在网点，所在地点，使用部门不能为空"
        elsif @atype.eql?"rent"
          flash[:alert] = "其他租赁资产明细不能为空,地点备注，使用部门不能为空"
        end
        if (@purchase.create_user_id == current_user.id) && (params[:source].eql?"index")
          respond_to do |format|
            format.html { redirect_to purchases_url(atype: @atype) }
            format.json { head :no_content }
          end
        else 
          respond_to do |format|
            format.html { redirect_to to_do_index_purchases_url(atype: @atype) }
            format.json { head :no_content }
          end
        end
      end
    end
  end

  def approve
    ActiveRecord::Base.transaction do 
      @purchase.update status: "done", checked_user_id: current_user.id, change_log: ((@purchase.change_log.blank? ? "" : @purchase.change_log)+Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}审核通过" + ",")

      if !params[:atype].blank? && (params[:atype].eql?"lvc")
        @purchase.low_value_consumption_infos.each do |l|
          asset_no = Sequence.generate_asset_no(l,l.created_at)
          l.update status: "in_use", use_at: Time.now, asset_no: asset_no
        end
      elsif !params[:atype].blank? && (params[:atype].eql?"rent")
        @purchase.rent_infos.each do |l|
          asset_no = Sequence.generate_asset_no(l,l.created_at)
          l.update status: "in_use", use_at: Time.now, asset_no: asset_no
        end
      end
    end
    
    respond_to do |format|
      format.html { redirect_to to_do_index_purchases_url(atype: @atype), notice: I18n.t('controller.approve_success_notice', model: "#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}") }
      format.json { head :no_content }
    end

  end

  def decline
    ActiveRecord::Base.transaction do 
      @purchase.update status: "declined", change_log: ((@purchase.change_log.blank? ? "" : @purchase.change_log) +Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}审核否决" + ",")

      if !params[:atype].blank? && (params[:atype].eql?"lvc")
        @purchase.low_value_consumption_infos.update_all status: "declined"
      elsif !params[:atype].blank? && (params[:atype].eql?"rent")
        @purchase.rent_infos.update_all status: "declined"
      end
    end

    respond_to do |format|
      format.html { redirect_to to_do_index_purchases_url(atype: @atype), notice: I18n.t('controller.decline_success_notice', model: "#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}") }
      format.json { head :no_content }
    end
  end

  def revoke
    if (["waiting", "declined"].include?@purchase.status and @purchase.is_send and @purchase.create_user_id == current_user.id )
      @purchase.update status: "revoked", manage_unit_id: current_user.unit_id, is_send: false, change_log: ((@purchase.change_log.blank? ? "" : @purchase.change_log)+Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"采购单撤回" + ",")
      @purchase.low_value_consumption_infos.update_all manage_unit_id: @purchase.manage_unit_id, status: "revoked"
    end

    respond_to do |format|
      format.html { redirect_to to_do_index_purchases_url, notice: I18n.t('controller.revoke_success_notice', model: "采购单") }
      format.json { head :no_content }
    end
  end

  def cancel
    ActiveRecord::Base.transaction do
      if ["revoked", "declined"].include?@purchase.status 
        @purchase.update status: "canceled", change_log: ((@purchase.change_log.blank? ? "" : @purchase.change_log)+Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}取消" + ",")
        @purchase.low_value_consumption_infos.update_all status: "canceled"
      end
    end

    respond_to do |format|
      format.html { redirect_to to_do_index_purchases_url(atype: params[:atype]), notice: I18n.t('controller.cancel_success_notice', model: "#{(@purchase.atype.eql?'lvc') ? '采购单' : '其他租赁资产'}") }
      format.json { head :no_content }
    end
  end

  def print
    @purchase
  end

  def print_certificate
    @purchase

    @lvc_infos = @purchase.low_value_consumption_infos.group(:asset_name, :lvc_catalog_id, :brand_model, :buy_at, :sum, :use_unit_id, :relevant_unit_id).order(:lvc_catalog_id, :asset_name, :buy_at).count
    @sum = @purchase.low_value_consumption_infos.sum(:sum)
    @count = @purchase.low_value_consumption_infos.count
  end

  def rent_print_certificate
    @purchase

    @rent_infos = @purchase.rent_infos.group(:asset_no, :asset_name, :fixed_asset_catalog_id, :brand_model, :use_unit_id, :relevant_unit_id).order(:fixed_asset_catalog_id, :asset_no, :asset_name).count
    @count = @purchase.rent_infos.count
  end



  private
    def set_purchase
      @purchase = Purchase.find(params[:id])
    end

    def purchase_params
      params.require(:purchase).permit(:no, :name, :desc)
    end
end
