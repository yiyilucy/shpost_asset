class FixedAssetInfosController < ApplicationController
  load_and_authorize_resource

  def index
    if current_user.unit.blank?
      @fixed_asset_infos = FixedAssetInfo.all.order(:unit_id, :fixed_asset_catalog_id)
    else
      if current_user.unit.unit_level == 1
        @fixed_asset_infos = FixedAssetInfo.all.order(:unit_id, :fixed_asset_catalog_id)
      elsif current_user.unit.is_facility_management_unit
        @fixed_asset_infos = FixedAssetInfo.where("(relevant_unit_id = ? or unit_id = ?)", current_user.unit_id, current_user.unit_id).order(:unit_id, :fixed_asset_catalog_id)
      elsif current_user.unit.unit_level == 2
        @fixed_asset_infos = FixedAssetInfo.where(manage_unit_id: current_user.unit_id).order(:unit_id, :fixed_asset_catalog_id)
      elsif current_user.unit.unit_level == 3 && !current_user.unit.is_facility_management_unit   
        @fixed_asset_infos = FixedAssetInfo.where("unit_id = ? or unit_id in (?)", current_user.unit_id, current_user.unit.children.map{|x| x.id}).order(:unit_id, :fixed_asset_catalog_id)
      end  
    end     
# binding.pry        
    @fixed_asset_infos_grid = initialize_grid(@fixed_asset_infos,
      :name => 'fixed_asset_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'fixed_asset_infos'
      # :csv_encoding => Encoding::GBK
      )

    export_grid_if_requested
  end

  def show
    respond_with(@fixed_asset_info)
  end

  def new
    @fixed_asset_info = FixedAssetInfo.new
    respond_with(@fixed_asset_info)
  end

  def edit
  end

  def create
    @fixed_asset_info = FixedAssetInfo.new(fixed_asset_info_params)
    @fixed_asset_info.save
    respond_with(@fixed_asset_info)
  end

  def update
    @fixed_asset_info.update(fixed_asset_info_params)
    respond_with(@fixed_asset_info)
  end

  def destroy
    @fixed_asset_info.destroy
    respond_with(@fixed_asset_info)
  end

  def fixed_asset_info_import
    unless request.get?
      if file = upload_fixed_asset_info(params[:file]['file'])       
        ActiveRecord::Base.transaction do
          begin
            ori_infos = FixedAssetInfo.where(manage_unit_id: current_user.unit_id).group(:asset_no).order(:asset_no).size

            catalogs = FixedAssetCatalog.all.group(:name).size
            catalogs.each do |key, value|
              catalogs[key] = FixedAssetCatalog.find_by(name: key).id
            end

            use_departments = Unit.all.group(:name).size
            use_departments.each do |key, value|
              use_departments[key] = Unit.find_by(name: key).id
            end

            relevant_departments = Unit.where(is_facility_management_unit: true).group(:name).size
            relevant_departments.each do |key, value|
              relevant_departments[key] = Unit.find_by(name: key).id
            end

            short_relevant_departments = Unit.where(is_facility_management_unit: true).group(:unit_desc).size
            short_relevant_departments.each do |key, value|
              short_relevant_departments[key] = Unit.find_by(unit_desc: key).id
            end
           
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"
            catalog_code = ""
            current_line = 0
            is_error = false

            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first
            title_row = instance.row(7)
            sn_index = title_row.index("资产序列号")
            asset_name_index = title_row.index("资产名称")
            asset_no_index = title_row.index("资产编号")
            catalog_name_index = title_row.index("资产类别名称")
            relevant_department_index = title_row.index("归口管理部门")
            use_at_index = title_row.index("启用日期")
            amount_index = title_row.index("数量")
            sum_index = title_row.index("原值")
            unit_name_index = title_row.index("使用部门")
            location_index = title_row.index("[存放地点]")
            user_index = title_row.index("资产使用人")
            # accounting_department_index = title_row.index("核算部门")
            belong_unit_index = title_row.index("归属管理")
            desc1_index = title_row.index("使用单位")
            use_years_index = title_row.index("使用年限")
            brand_model_index = title_row.index("结构/型号")
            location_desc_index = title_row.index("地点备注")
            accumulate_depreciation_index = title_row.index("累计折旧")
            net_value_index = title_row.index("账面净值")
            month_depreciation_index = title_row.index("本月折旧")
            use_status_index = title_row.index("使用状态")
            license_index = title_row.index("[牌照]")
            
            8.upto(instance.last_row) do |line|
              # binding.pry
              current_line = line
              rowarr = instance.row(line)
              if (rowarr[0].blank? and rowarr[1].blank?) or rowarr[0].eql?"合计"
                break
              end
              sn = rowarr[sn_index].blank? ? "" : rowarr[sn_index].to_s.split('.0')[0][0,rowarr[sn_index].to_s.split('.0')[0].length-1]
              asset_name = rowarr[asset_name_index].blank? ? "" : rowarr[asset_name_index].to_s
              asset_no = rowarr[asset_no_index].blank? ? "" : rowarr[asset_no_index].to_s.split('.0')[0]
              catalog_name = rowarr[catalog_name_index].blank? ? "" : rowarr[catalog_name_index].to_s.split(".").last.strip
              relevant_department =rowarr[relevant_department_index].blank? ? "" : to_string(rowarr[relevant_department_index])
              # buy_at = rowarr[6].blank? ? nil : DateTime.parse(rowarr[6].to_s).strftime('%Y-%m-%d')
              use_at = rowarr[use_at_index].blank? ? nil : DateTime.parse(rowarr[use_at_index].to_s).strftime('%Y-%m-%d')
              # measurement_unit = to_string(rowarr[8])
              amount = rowarr[amount_index].blank? ? 0 : rowarr[amount_index].to_i
              sum = rowarr[sum_index].blank? ? 0.0 : rowarr[sum_index].to_f
              unit_name = rowarr[unit_name_index].blank? ? "" : to_string(rowarr[unit_name_index])
              # branch = to_string(rowarr[12])
              location = rowarr[location_desc_index].blank? ? rowarr[location_index] : to_string(rowarr[location_desc_index])
              user = rowarr[user_index].blank? ? "" : to_string(rowarr[user_index])
              # change_log = to_string(rowarr[15])
              # accounting_department = rowarr[accounting_department_index].blank? ? "" : to_string(rowarr[accounting_department_index])
              belong_unit = rowarr[belong_unit_index].blank? ? "" : to_string(rowarr[belong_unit_index])
              desc1 = rowarr[desc1_index].blank? ? "" : to_string(rowarr[desc1_index])
              use_years = rowarr[use_years_index].blank? ? "" : to_string(rowarr[use_years_index])
              brand_model = rowarr[brand_model_index].blank? ? "" : to_string(rowarr[brand_model_index])
              accumulate_depreciation = rowarr[accumulate_depreciation_index].blank? ? 0.0 : rowarr[accumulate_depreciation_index].to_f
              net_value = rowarr[net_value_index].blank? ? 0.0 : rowarr[net_value_index].to_f
              month_depreciation = rowarr[month_depreciation_index].blank? ? 0.0 : rowarr[month_depreciation_index].to_f
              use_status = rowarr[use_status_index].blank? ? "" : to_string(rowarr[use_status_index])
              license = rowarr[license_index].blank? ? "" : to_string(rowarr[license_index])
              
              if asset_name.blank?
                is_error = true
                txt = "缺少资产名称"
                sheet_error << (rowarr << txt)
                next
              end
              if asset_no.blank?
                is_error = true
                txt = "缺少资产编号"
                sheet_error << (rowarr << txt)
                next
              end
              if catalog_name.blank?
                is_error = true
                txt = "缺少类别目录"
                sheet_error << (rowarr << txt)
                next
              end
              
              if !catalogs.has_key?catalog_name
                is_error = true
                txt = "类别目录不存在"
                sheet_error << (rowarr << txt)
                next
              end
              if unit_name.blank?
                is_error = true
                txt = "缺少使用部门"
                sheet_error << (rowarr << txt)
                next
              end
              if !use_departments.has_key?unit_name
                is_error = true
                txt = "使用部门不存在"
                sheet_error << (rowarr << txt)
                next
              end
              if relevant_department.blank?
                is_error = true
                txt = "缺少归口管理部门"
                sheet_error << (rowarr << txt)
                next
              end
              if !relevant_department.blank?
                if !relevant_departments.has_key?relevant_department and !short_relevant_departments.has_key?relevant_department
                  is_error = true
                  txt = "归口管理部门不存在"
                  sheet_error << (rowarr << txt)
                  next
                end
              end

              sheet_error << (rowarr << txt)

              ori_info = FixedAssetInfo.find_by(asset_no:asset_no)

              if !ori_info.blank?
                ori_info.update!(sum: sum, accumulate_depreciation: accumulate_depreciation, net_value: net_value, month_depreciation: month_depreciation, use_status: use_status, user: user, unit_id: use_departments[unit_name], location:location, relevant_unit_id: relevant_departments[relevant_department].blank? ? short_relevant_departments[relevant_department] : relevant_departments[relevant_department], desc1: desc1, license: license, status:"in_use", manage_unit_id: current_user.unit_id)

                ori_infos.delete(asset_no)
              else
                FixedAssetInfo.create!(sn: sn, asset_name: asset_name, asset_no: asset_no, fixed_asset_catalog_id: catalogs[catalog_name], relevant_unit_id: relevant_departments[relevant_department].blank? ? short_relevant_departments[relevant_department] : relevant_departments[relevant_department], use_at:use_at, amount:amount, sum:sum, unit_id: use_departments[unit_name], location:location, user:user, status:"in_use", print_times:0, manage_unit_id: current_user.unit_id, belong_unit: belong_unit, desc1: desc1, use_years: use_years, brand_model: brand_model, accumulate_depreciation: accumulate_depreciation, net_value: net_value, month_depreciation: month_depreciation, use_status: use_status, license: license)
              end
            end

            if !ori_infos.blank?
              ori_infos.each do |key,value|
                FixedAssetInfo.find_by(asset_no:key).update(status:"discard")
              end
            end

            # if !sheet_error.blank?
            if is_error
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message

            # if !sheet_error.blank?
            if is_error
              send_data(exporterrorfixed_asset_infos_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Fixed_Asset_Infos_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to :action => 'index'
            end

          rescue Exception => e
            flash[:alert] = e.message + "第" + current_line.to_s + "行"
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def exporterrorfixed_asset_infos_xls_content_for(obj,title_row)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Fixed_Asset_Infos"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    red = Spreadsheet::Format.new :color => :red
    sheet1.row(0).default_format = blue 
    # sheet1.row(0).concat %w{序号 资产名称 资产编号 类别名称 类别目录 归口管理部门 购买日期 领用日期 计量单位 数量 金额 使用部门 所在网点 所在地点 使用人 变动记录} 
    sheet1.row(6).concat title_row
    size = obj.first.size 
    count_row = 7
    obj.each do |obj|
      count = 0
      while count<=size
        sheet1[count_row,count]=obj[count]
        count += 1
      end
      
      count_row += 1
    end 
    book.write xls_report  
    xls_report.string  
  end

  def to_string(text)
    if text.is_a? Float
      return text.to_s.split('.0')[0]
    else
      return text
    end
  end

  def print
    if params[:fixed_asset_infos] && params[:fixed_asset_infos][:selected]
      @selected = params[:fixed_asset_infos][:selected]
      
      @result = []
      
      until @selected.blank? do 
        @result = @result + FixedAssetInfo.where(id:@selected.pop(1000))
      end

      @result.sort_by{|x| "#{x.unit_id.to_s} #{x.fixed_asset_catalog_id.to_s}"}

      # @result.sort_by{|x| "#{x.unit_id.to_s} #{x.fixed_asset_catalog_id.to_s}"}.each{|x| puts "#{x.id}  #{x.unit_id}  #{x.fixed_asset_catalog_id}"}
    else
      flash[:alert] = "请勾选需要打印的固定资产"
      respond_to do |format|
        format.html { redirect_to fixed_asset_infos_url }
        format.json { head :no_content }
      end
    end
    # binding.pry
  end

  def to_scan
    @fixed_asset_info = nil
    
    if !params.blank? and !params[:id].blank?
      @fixed_asset_info = FixedAssetInfo.find(params[:id].to_i)
      
      fixed_asset_inventory_details = FixedAssetInventoryDetail.joins(:fixed_asset_inventory).where("fixed_asset_inventory_details.fixed_asset_info_id = ? and fixed_asset_inventories.status = ?", @fixed_asset_info.id, "doing").order("fixed_asset_inventories.start_time desc")

      if !fixed_asset_inventory_details.blank?
        @fixed_asset_inventory_detail = fixed_asset_inventory_details.first
        @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory

        respond_to do |format|
          format.html { redirect_to scan_fixed_asset_inventory_detail_path(@fixed_asset_inventory_detail) }
          format.json { head :no_content }
        end
      end
    end
  end

  def fixed_asset_report
    if current_user.unit.unit_level == 1
      @sums = FixedAssetInfo.where(status: "in_use").group(:manage_unit_id).order(:manage_unit_id).sum(:sum)
      @counts = FixedAssetInfo.where(status: "in_use").group(:manage_unit_id).order(:manage_unit_id).count
      @total_sum = FixedAssetInfo.where(status: "in_use").sum(:sum)
      @total_count = FixedAssetInfo.where(status: "in_use").size
      @units = Unit.where(unit_level: 2).map{|x| x.id}.select(:id, :name)
    elsif current_user.unit.unit_level == 2
      @sums = FixedAssetInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").group(:unit_id).order(:unit_id).sum(:sum)
      @counts = FixedAssetInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").group(:unit_id).order(:unit_id).count
      @total_sum = FixedAssetInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").sum(:sum)
      @total_count = FixedAssetInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").size
      @units = Unit.where("units.id = ? or units.parent_id = ? or units.parent_id in (?)", current_user.unit_id, current_user.unit_id, current_user.unit.children.map{|x| x.id}).select(:id, :name)
    end
  end

  # def export()
  #   if current_user.unit.unit_level == 1
  #     @fixed_asset_infos = FixedAssetInfo.all.order(:relevant_department, :manage_unit_id, :asset_no)
  #   elsif current_user.unit.unit_level == 2 and current_user.unit.is_facility_management_unit
  #     @fixed_asset_infos = FixedAssetInfo.where(relevant_department: current_user.unit_id).order(:manage_unit_id, :asset_no)
  #   elsif current_user.unit.unit_level == 2 and !current_user.unit.is_facility_management_unit
  #     @fixed_asset_infos = FixedAssetInfo.where(manage_unit_id: current_user.unit_id).order(:asset_no)
  #   end  

  #   infos = filter_query_infos(@fixed_asset_infos,params)
  #   # binding.pry
  #   if infos.blank?
  #     flash[:alert] = "无信息"
  #     redirect_to :action => 'index'
  #   else
  #     respond_to do |format|
  #       format.xls {   
  #         send_data(exportinfos_xls_content_for(infos), :type => "text/excel;charset=utf-8; header=present", :filename => "FixedAssetInfos_#{Time.now.to_i}.xls")  
  #       }  
  #     end
  #   end

  # end

  # def filter_query_infos(infos, params)
  #   # binding.pry
  #   selectinfos = infos
  #   if !params[:grid].blank?
  #     if !params[:grid][:f].blank?
  #       params_f = params[:grid][:f]
  #       if !params_f[:asset_name].blank?
  #         selectinfos=selectinfos.where(asset_name: params_f[:asset_name])
  #       end
  #       if !params_f[:asset_no].blank?
  #         selectinfos=selectinfos.where(asset_no: params_f[:asset_no])
  #       end
  #       if !params_f["fixed_asset_catalogs.code"].blank?
  #         selectinfos=selectinfos.joins(:fixed_asset_catalog).where("fixed_asset_catalogs.code like ? or fixed_asset_catalogs.name like ?", "%#{params_f["fixed_asset_catalogs.code"]}%", "%#{params_f["fixed_asset_catalogs.code"]}%")
  #       end
  #       if !params_f[:relevant_department].blank?
  #         if !params_f[:relevant_department][:eq].blank?
  #           selectinfos=selectinfos.joins("LEFT JOIN units ON fixed_asset_infos.relevant_department=units.id").where("units.name like ?", "%#{params_f[:relevant_department][:eq]}%")
  #         end
  #       end
  #       if !params_f[:buy_at].blank?
  #         if !params_f[:buy_at][:fr].blank?
  #           selectinfos=selectinfos.where("fixed_asset_infos.buy_at >= ?",params_f[:buy_at][:fr])
  #         end
  #         if !params_f[:buy_at][:to].blank?
  #           selectinfos=selectinfos.where("fixed_asset_infos.buy_at <= ?",params_f[:buy_at][:to]+" 23:59:59")
  #         end
  #       end
  #       if !params_f[:use_at].blank?
  #         if !params_f[:use_at][:fr].blank?
  #           selectinfos=selectinfos.where("fixed_asset_infos.use_at >= ?",params_f[:use_at][:fr])
  #         end
  #         if !params_f[:use_at][:to].blank?
  #           selectinfos=selectinfos.where("fixed_asset_infos.use_at <= ?",params_f[:use_at][:to]+" 23:59:59")
  #         end
  #       end
  #       if !params_f[:measurement_unit].blank?
  #         selectinfos=selectinfos.where(measurement_unit: params_f[:measurement_unit])
  #       end
  #       if !params_f["units.name"].blank?
  #         selectinfos=selectinfos.joins(:unit).where("units.name like ?", "%#{params_f["units.name"]}%")
  #       end
  #       if !params_f[:branch].blank?
  #         selectinfos=selectinfos.where(branch: params_f[:branch])
  #       end
  #       if !params_f[:location].blank?
  #         selectinfos=selectinfos.where(location: params_f[:location])
  #       end
  #       if !params_f[:user].blank?
  #         selectinfos=selectinfos.where(user: params_f[:user])
  #       end
  #       if !params_f[:status].blank?
  #         if !params_f[:status][0].blank?
  #           selectinfos=selectinfos.where(status: params_f[:status][0])
  #         end
  #       end
  #     end
  #   end
  #   selectinfos=selectinfos.order('fixed_asset_infos.asset_no')
  #   return selectinfos
  # end

  # def exportinfos_xls_content_for(objs)  
  #   xls_report = StringIO.new  
  #   book = Spreadsheet::Workbook.new  
  #   sheet1 = book.create_worksheet :name => "fixed_asset_infos"  
    
  #   blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
  #   sheet1.row(0).default_format = blue  
  
  #   sheet1.row(0).concat %w{序号 资产名称 资产编号 类别名称 类别目录 归口管理部门 购买日期 领用日期 计量单位 数量 金额 使用部门 所在网点 所在地点 使用人 变动记录}  
  #   count_row = 1
  #   objs.each do |obj|  
  #     sheet1[count_row,0]=obj.sn
  #     sheet1[count_row,1]=obj.asset_name
  #     sheet1[count_row,2]=obj.asset_no
  #     sheet1[count_row,3]=obj.fixed_asset_catalog.try :name
  #     sheet1[count_row,4]=obj.fixed_asset_catalog.try :code
  #     sheet1[count_row,5]=obj.relevant_department
  #     sheet1[count_row,6]=obj.buy_at.blank? ? "" : obj.buy_at.strftime('%Y-%m-%d')
  #     sheet1[count_row,7]=obj.use_at.blank? ? "" : obj.use_at.strftime('%Y-%m-%d')
  #     sheet1[count_row,8]=obj.measurement_unit
  #     sheet1[count_row,9]=obj.amount
  #     sheet1[count_row,10]=obj.sum
  #     sheet1[count_row,11]=obj.unit.try :name
  #     sheet1[count_row,12]=obj.branch
  #     sheet1[count_row,13]=obj.location
  #     sheet1[count_row,14]=obj.user
  #     sheet1[count_row,15]=obj.change_log

  #     count_row += 1
  #   end
      
  #   book.write xls_report  
  #   xls_report.string  
  # end



  private
    def set_fixed_asset_info
      @fixed_asset_info = FixedAssetInfo.find(params[:id])
    end

    def fixed_asset_info_params
      params[:fixed_asset_info]
    end

    def upload_fixed_asset_info(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/fixed_asset_info/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end
        file_path
      end
    end
end
