class PurchaseLowValueConsumptionInfoController < ApplicationController
  load_and_authorize_resource :purchase
  load_and_authorize_resource :low_value_consumption_info, through: :purchase, parent: false

  def index
    # binding.pry
    @low_value_consumption_infos = @low_value_consumption_infos.order(:use_unit_id, :lvc_catalog_id)
    @low_value_consumption_infos_grid = initialize_grid(@low_value_consumption_infos,
      :per_page => params[:page_size],
      :name => 'purchase_low_value_consumption_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_infos')

    export_grid_if_requested

  end

  def show
  end

  def new
  end
  def import
    unless request.get?
      if file = upload_low_value_consumption_info(params[:file]['file'])       
        ActiveRecord::Base.transaction do
          begin
            catalogs = LowValueConsumptionCatalog.all.group(:code).size
            catalogs.each do |key, value|
              catalogs[key] = LowValueConsumptionCatalog.find_by(code: key).id
            end

            use_units = Unit.all.group(:name).size
            use_units.each do |key, value|
              use_units[key] = Unit.find_by(name: key).id
            end

            relevant_units = Unit.where(is_facility_management_unit: true).group(:name).size
            relevant_units.each do |key, value|
              relevant_units[key] = Unit.find_by(name: key).id
            end

            short_relevant_units = Unit.where(is_facility_management_unit: true).group(:unit_desc).size
            short_relevant_units.each do |key, value|
              short_relevant_units[key] = Unit.find_by(unit_desc: key).id
            end
           
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"
            catalog_code = ""
            current_line = 0

            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first
            title_row = instance.row(1)
            
            catalog_code_index = title_row.index("资产类别编码")
            branch_index =title_row.index("所在网点")
            batch_no_index = title_row.index("生产批次")
            asset_name_index = title_row.index("资产名称")
            amount_index = title_row.index("数量")
            buy_at_index =title_row.index("购买日期")
            sum_index = title_row.index("原值")
            brand_model_index = title_row.index("结构/型号")
            measurement_unit_index = title_row.index("计量单位")
            location_index = title_row.index("所在地点")
            use_user_index = title_row.index("资产使用人")
            relevant_unit_index = title_row.index("归口管理部门")
            use_unit_index = title_row.index("使用部门")
            change_log_index = title_row.index("变动记录")
            status_index = title_row.index("状态")
            print_times_index = title_row.index("标签打印次数")
            use_years_index = title_row.index("使用年限")
            desc1_index = title_row.index("备注")
            is_rent_index = title_row.index("是否租赁")
            
            
            2.upto(instance.last_row) do |line|
              # binding.pry
              current_line = line
              rowarr = instance.row(line)
              if (rowarr[0].blank? and rowarr[1].blank?) or rowarr[0].eql?"合计"
                break
              end
              asset_name = rowarr[asset_name_index].blank? ? "" : to_string(rowarr[asset_name_index])
              catalog_code = rowarr[catalog_code_index].blank? ? "" : rowarr[catalog_code_index].to_s
              relevant_unit =rowarr[relevant_unit_index].blank? ? "" : to_string(rowarr[relevant_unit_index])
              buy_at = rowarr[buy_at_index].blank? ? nil : DateTime.parse(rowarr[buy_at_index].to_s).strftime('%Y-%m-%d')
              # buy_at = rowarr[buy_at_index].blank? ? nil : DateTime.parse(rowarr[buy_at_index].to_s.split(".0")[0]).strftime('%Y-%m-%d')
              batch_no = to_string(rowarr[batch_no_index])
              measurement_unit = to_string(rowarr[measurement_unit_index])
              amount = rowarr[amount_index].blank? ? 0 : rowarr[amount_index].to_i
              sum = rowarr[sum_index].blank? ? 0.0 : rowarr[sum_index].to_f
              use_unit = rowarr[use_unit_index].blank? ? "" : to_string(rowarr[use_unit_index])
              branch = to_string(rowarr[branch_index])
              location = rowarr[location_index].blank? ? "" : rowarr[location_index].to_s
              use_user = rowarr[use_user_index].blank? ? "" : rowarr[use_user_index].to_s
              change_log = to_string(rowarr[change_log_index])
              # accounting_department = rowarr[accounting_department_index].blank? ? "" : to_string(rowarr[accounting_department_index])
              desc1 = rowarr[desc1_index].blank? ? "" : to_string(rowarr[desc1_index])
              use_years = rowarr[use_years_index].blank? ? "" : rowarr[use_years_index].to_s.split(".0")[0]
              brand_model = rowarr[brand_model_index].blank? ? "" : to_string(rowarr[brand_model_index])
              is_rent = rowarr[is_rent_index].blank? ? false : ((to_string(rowarr[is_rent_index]).eql?"是") ? true : false)
              @purchase_id = params[:purchase_id]
              if asset_name.blank?
                txt = "缺少资产名称_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback         
              end
              if catalog_code.blank?
                txt = "缺少资产类别编码_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end
              
              if !catalogs.has_key?catalog_code
                txt = "类别目录不存在_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end

              if relevant_unit.blank?
                txt = "缺少归口管理部门_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end
              

              if !relevant_unit.blank?
                if !relevant_units.has_key?relevant_unit and !short_relevant_units.has_key?relevant_unit
                  txt = "归口管理部门不存在_"
                  sheet_error << (rowarr << txt)
                  raise txt
                  raise ActiveRecord::Rollback 
                end
              end

              if !amount.is_a?(Integer) or amount <= 0
                txt = "请填写正确数量_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end

              if buy_at.blank?
                txt = "缺少购买日期_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end
              if brand_model.blank?
                txt = "缺少结构/型号_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end
              if sum.blank?
                txt = "原值_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end

              if use_unit.blank?
                txt = "缺少使用部门_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end
              
              while amount>0
                lvc_info = LowValueConsumptionInfo.create!(asset_name: asset_name, lvc_catalog_id: catalogs[catalog_code], relevant_unit_id: relevant_units[relevant_unit].blank? ? short_relevant_units[relevant_unit] : relevant_units[relevant_unit], change_log: change_log, batch_no: batch_no, use_unit_id: use_units[use_unit], measurement_unit: measurement_unit, branch: branch, buy_at: buy_at, sum:sum, location: location, use_user: use_user, status: "waiting", print_times: 0, manage_unit_id: current_user.unit_id, desc1: desc1, use_years: use_years, brand_model: brand_model, is_rent: is_rent, purchase_id: @purchase_id)
                # lvc_info.update asset_no: Sequence.generate_asset_no(lvc_info,lvc_info.buy_at)

                amount = amount - 1
              end
            end

            if !sheet_error.blank?
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message

            if !sheet_error.blank?
              send_data(exporterrorlow_value_consumption_infos_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Low_Value_Consumption_Infos_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to purchase_low_value_consumption_infos_url
            end

          rescue Exception => e
            Rails.logger.error e.backtrace
            flash[:alert] = e.message + "第" + current_line.to_s + "行"
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end
  def to_string(text)
    if text.is_a? Float
      return text.to_s.split('.0')[0]
    else
      return text
    end
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
          LowValueConsumptionInfo.create!(lvc_catalog_id: params[:low_value_consumption_info][:lvc_catalog_id], 
            asset_name: params[:low_value_consumption_info][:asset_name], 
            batch_no: params[:low_value_consumption_info][:batch_no], 
            brand_model: params[:low_value_consumption_info][:brand_model], 
            measurement_unit: params[:low_value_consumption_info][:measurement_unit], 
            sum: params[:low_value_consumption_info][:sum], 
            buy_at: params[:low_value_consumption_info][:buy_at], 
            branch: params[:low_value_consumption_info][:branch],
            location: params[:low_value_consumption_info][:location], 
            use_user: params[:low_value_consumption_info][:use_user], 
            relevant_unit_id: params[:low_value_consumption_info][:relevant_unit_id], 
            use_unit_id: params[:low_value_consumption_info][:use_unit_id], 
            change_log: params[:low_value_consumption_info][:change_log], 
            purchase_id: @purchase.id, 
            status: "waiting", 
            print_times: 0, 
            manage_unit_id: @purchase.manage_unit_id,
            use_years: params[:low_value_consumption_info][:use_years],
            desc1: params[:low_value_consumption_info][:desc1],
            is_rent: (params[:low_value_consumption_info][:is_rent].eql?"1"))
          
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
            # @low_value_consumption_info.sn = params[:sn]
            if !params[:low_value_consumption_info][:lvc_catalog_id].blank?
              @low_value_consumption_info.lvc_catalog_id = params[:low_value_consumption_info][:lvc_catalog_id]
            end
            if !params[:asset_name].blank? && !params[:asset_name].strip.blank?
              @low_value_consumption_info.asset_name = params[:asset_name]
            end
            if !params[:batch_no].blank? && !params[:batch_no].strip.blank?
              @low_value_consumption_info.batch_no = params[:batch_no]
            end
            if !params[:brand_model].blank? && !params[:brand_model].strip.blank?
              @low_value_consumption_info.brand_model = params[:brand_model]
            end
            if !params[:measurement_unit].blank? && !params[:measurement_unit].strip.blank?
              @low_value_consumption_info.measurement_unit = params[:measurement_unit]
            end
            if !params[:sum].blank? && !params[:sum].strip.blank?
              @low_value_consumption_info.sum = params[:sum]
            end           
            if !params[:change_log].blank? && !params[:change_log].strip.blank?
              @low_value_consumption_info.change_log = params[:change_log]
            end
            if !params[:use_years].blank? && !params[:use_years].strip.blank?
              @low_value_consumption_info.use_years = params[:use_years]
            end
            @low_value_consumption_info.is_rent = params[:checkbox][:is_rent].eql?"1"
          end
          if !params[:branch].blank? && !params[:branch].strip.blank?
            @low_value_consumption_info.branch = params[:branch]
          end
          if !params[:location].blank? && !params[:location].strip.blank?
            @low_value_consumption_info.location = params[:location]
          end
          if !params[:use_user].blank? && !params[:use_user].strip.blank?
            @low_value_consumption_info.use_user = params[:use_user]
          end
          if !params[:low_value_consumption_info][:relevant_unit_id].blank?
            @low_value_consumption_info.relevant_unit_id = params[:low_value_consumption_info][:relevant_unit_id]
          end
          if !params[:low_value_consumption_info][:use_unit_id].blank?
            @low_value_consumption_info.use_unit_id = params[:low_value_consumption_info][:use_unit_id]
          end
          if !params[:desc1].blank? && !params[:desc1].strip.blank?
            @low_value_consumption_info.desc1 = params[:desc1]
          end
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
      @result = []
      
      until @selected.blank? do 
        @result = @result + LowValueConsumptionInfo.where(id:@selected.pop(1000))
      end

      # @result.sort_by{|x| "#{x.asset_no}"}
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
    params.require(:low_value_consumption_info).permit(:asset_name, :lvc_catalog_id, :relevant_unit_id, :buy_at, :measurement_unit, :sum, :use_unit_id, :branch, :location, :use_user, :brand_model, :batch_no, :manage_unit_id, :use_years, :desc1, :is_rent)
  end
  def upload_low_value_consumption_info(file)
    if !file.original_filename.empty?
      direct = "#{Rails.root}/upload/low_value_consumption_info/"
      filename = "#{Time.now.to_f}_#{file.original_filename}"

      file_path = direct + filename
      File.open(file_path, "wb") do |f|
         f.write(file.read)
      end
      file_path
    end
  end
end