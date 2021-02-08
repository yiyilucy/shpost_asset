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
  def import
    unless request.get?
      if file = upload_rent_info(params[:file]['file'])       
        ActiveRecord::Base.transaction do
          begin
            catalogs = FixedAssetCatalog.all.group(:name).size
            catalogs.each do |key, value|
              catalogs[key] = FixedAssetCatalog.find_by(name: key).id
            end
            codes = FixedAssetCatalog.all.group(:name).size
            codes.each do |key, value|
              codes[key] = FixedAssetCatalog.find_by(name: key).code[0,2]
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
            ori_asset_no_index = title_row.index("原资产编号")            
            asset_name_index = title_row.index("资产名称")
            catalog_name_index = title_row.index("资产类别名称")
            use_at_index = title_row.index("启用日期")
            amount_index = title_row.index("数量")
            brand_model_index = title_row.index("结构/型号")
            use_user_index = title_row.index("资产使用人")
            use_unit_index = title_row.index("使用部门")
            location_index = title_row.index("地点备注")
            area_index = title_row.index("[建筑面积（平方米）]")
            sum_index = title_row.index("[租金总金额]")
            use_right_start_index = title_row.index("[使用权取得日期]")
            use_right_end_index = title_row.index("[使用权终止日期]")
            pay_cycle_index = title_row.index("[租赁费支付周期]")
            license_index = title_row.index("[牌照]")
            deposit_index = title_row.index("[租赁押金]")
            relevant_unit_index = title_row.index("归口管理部门")
            # manage_unit_index = title_row.index("管理部门")
            # status_index = title_row.index("状态")
            # print_times_index = title_row.index("标签打印次数")
            desc_index = title_row.index("备注")
            
            
            
            2.upto(instance.last_row) do |line|
              current_line = line
              rowarr = instance.row(line)
              if (rowarr[0].blank? and rowarr[1].blank?) or rowarr[0].eql?"合计"
                break
              end
              ori_asset_no = rowarr[ori_asset_no_index].blank? ? "" : to_string(rowarr[ori_asset_no_index])
              asset_name = rowarr[asset_name_index].blank? ? "" : to_string(rowarr[asset_name_index])
              catalog_name = rowarr[catalog_name_index].blank? ? "" : to_string(rowarr[catalog_name_index])
              relevant_unit =rowarr[relevant_unit_index].blank? ? "" : to_string(rowarr[relevant_unit_index])
              use_at = rowarr[use_at_index].blank? ? nil : DateTime.parse(rowarr[use_at_index].to_s).strftime('%Y-%m-%d')
              amount = rowarr[amount_index].blank? ? 0 : rowarr[amount_index].to_i
              sum = rowarr[sum_index].blank? ? 0.0 : rowarr[sum_index].to_f
              use_unit = rowarr[use_unit_index].blank? ? "" : to_string(rowarr[use_unit_index])
              location = rowarr[location_index].blank? ? "" : to_string(rowarr[location_index])
              use_user = rowarr[use_user_index].blank? ? "" : rowarr[use_user_index].to_s
              desc = rowarr[desc_index].blank? ? "" : to_string(rowarr[desc_index])
              brand_model = rowarr[brand_model_index].blank? ? "" : to_string(rowarr[brand_model_index])
              # @purchase_id = params[:purchase_id]
              use_right_start =  rowarr[use_right_start_index].blank? ? nil : DateTime.parse(rowarr[use_right_start_index].to_s).strftime('%Y-%m-%d')
              use_right_end =  rowarr[use_right_end_index].blank? ? nil : DateTime.parse(rowarr[use_right_end_index].to_s).strftime('%Y-%m-%d')
              area = rowarr[area_index].blank? ?  nil : rowarr[area_index].to_f
              pay_cycle = rowarr[pay_cycle_index].blank? ? "" : rowarr[pay_cycle_index].to_s
              license = rowarr[license_index].blank? ? "" : rowarr[license_index].to_s 
              deposit = rowarr[deposit_index].blank? ? 0.0 : rowarr[deposit_index].to_f
              @purchase_id = params[:purchase_id]
              if asset_name.blank?
                txt = "缺少资产名称_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback         
              end
              if catalog_name.blank?
                txt = "缺少资产类别_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end
              
              if !catalogs.has_key?catalog_name
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

              if use_at.blank?
                txt = "缺少启用日期_"
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
                txt = "缺少租金总金额_"
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

              if location.blank?
                txt = "缺少地点备注_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end

              if use_right_start.blank?
                txt = "缺少[使用权取得日期]_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end 

              if use_right_end.blank?
                txt = "缺少[使用权终止日期]_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end 

              if pay_cycle.blank?
                txt = "缺少[租赁费支付周期]_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end

              if deposit.blank?
                txt = "缺少[租赁押金]_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end

              if  codes[catalog_name]== '01' and area.blank?
                txt = "缺少[建筑面积（平方米）]_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end

              if  codes[catalog_name]== '04' and license.blank?
                txt = "缺少[牌照]_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end

              
              while amount>0
                rent_info = RentInfo.create!(asset_name: asset_name, fixed_asset_catalog_id: catalogs[catalog_name], amount: amount, relevant_unit_id: relevant_units[relevant_unit].blank? ? short_relevant_units[relevant_unit] : relevant_units[relevant_unit],  use_unit_id: use_units[use_unit], use_user: use_user, use_at: use_at, sum:sum, location: location, status: "waiting", print_times: 0, desc: desc, brand_model: brand_model, pay_cycle: pay_cycle, area: area, use_right_start: use_right_start, use_right_end: use_right_end, license: license, deposit: deposit, ori_asset_no: ori_asset_no, manage_unit_id: current_user.unit_id, purchase_id: @purchase_id)
                # lvc_info.update asset_no: Sequence.generate_asset_no(lvc_info,lvc_info.buy_at)

                amount = amount - 1
              end
            end

            if !sheet_error.blank?
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message

            if !sheet_error.blank?
              send_data(exporterrorrent_infos_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Low_Value_Consumption_Infos_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to purchase_rent_infos_url
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

  def batch_edit
    @relename = ''
    @usename = ''
    @fixed_asset_catalog = ''
    @rentids = ""
# binding.pry
 
    if !params["purchase_rent_infos"].blank? and !params["purchase_rent_infos"]["selected"].blank?
      @rentids = params["purchase_rent_infos"]["selected"].compact.join(",")
      @rent_info = RentInfo.find(params["purchase_rent_infos"]["selected"].first.to_i)
    
      if !@rent_info.relevant_unit_id.blank?
        @relename = Unit.find_by(id: @rent_info.relevant_unit_id).try(:name)
      end
      if !@rent_info.use_unit_id.blank?
        @usename = Unit.find_by(id: @rent_info.use_unit_id).try(:name)
      end
      @fixed_asset_catalog = FixedAssetCatalog.find_by(id: @rent_info.fixed_asset_catalog_id).try(:name)
    else
      respond_to do |format|
          format.html { redirect_to purchase_rent_infos_url, alert: "请勾选其他租赁资产" }
          format.json { head :no_content }
      end
    end
  end
  def batch_update
    ActiveRecord::Base.transaction do
      # binding.pry
      if !params[:rentids].blank?
        params[:rentids].split(",").map(&:to_i).each do |id|
          @rent_info = RentInfo.find_by(id:id.to_i)
          if !params[:location].blank? && !params[:location].strip.blank?
            @rent_info.location = params[:location]
          end
          if !params[:use_user].blank? && !params[:use_user].strip.blank?
            @rent_info.use_user = params[:use_user]
          end
          if !params[:rent_info][:relevant_unit_id].blank?
            @rent_info.relevant_unit_id = params[:rent_info][:relevant_unit_id]
          end
          if !params[:rent_info][:use_unit_id].blank?
            @rent_info.use_unit_id = params[:rent_info][:use_unit_id]
          end
          @rent_info.update log: (@rent_info.log.blank? ? "" : @rent_info.log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"低值易耗品信息批量修改" + ","
          if !params[:desc].blank? && !params[:desc].strip.blank?
            @rent_info.desc = params[:desc]
          end
          if !params[:rent_info][:fixed_asset_catalog_id].blank?
            @rent_info.fixed_asset_catalog_id = params[:rent_info][:fixed_asset_catalog_id]
          end
          @rent_info.save
        end
        flash[:notice] = "批量修改成功"
        redirect_to purchase_rent_infos_path(@purchase)
      else
        flash[:alert] = "请勾选其他租赁资产"
        redirect_to purchase_rent_infos_path(@purchase)
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

  def batch_destroy
    # binding.pry
    ActiveRecord::Base.transaction do
      if !params["purchase_rent_infos"].blank? and !params["purchase_rent_infos"]["selected"].blank?
        LowValueConsumptionInfo.batch_destroy(RentInfo, params["purchase_rent_infos"]["selected"])
        flash[:notice] = "批量删除成功"
      end
    end
    redirect_to purchase_rent_infos_path(@purchase)
  end

  private

  def set_relationship
    @rent_info = RentInfo.find(params[:id])
  end

  def upload_rent_info(file)
    if !file.original_filename.empty?
      direct = "#{Rails.root}/upload/rent_info/"
      filename = "#{Time.now.to_f}_#{file.original_filename}"

      file_path = direct + filename
      File.open(file_path, "wb") do |f|
         f.write(file.read)
      end
      file_path
    end
  end  

  def rent_info_params
    params.require(:rent_info).permit(:asset_name, :asset_no, :fixed_asset_catalog_id, :use_at, :amount, :brand_model, :use_user, :use_unit_id, :location, :area, :sum, :use_right_start, :use_right_end, :pay_cycle, :license, :deposit, :relevant_unit_id, :manage_unit_id, :desc, :is_rent, :is_reprint, :change_log)
  end

end