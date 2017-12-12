class FixedAssetInfosController < ApplicationController
  load_and_authorize_resource

  def index
    if current_user.unit.blank?
      @fixed_asset_infos = FixedAssetInfo.all
    else
      if current_user.unit.unit_level == 1
        @fixed_asset_infos = FixedAssetInfo.all.order(:relevant_unit_id, :manage_unit_id, :asset_no)
      elsif current_user.unit.unit_level == 2 and current_user.unit.is_facility_management_unit
        @fixed_asset_infos = FixedAssetInfo.where(relevant_unit_id: current_user.unit_id).order(:manage_unit_id, :asset_no)
      elsif current_user.unit.unit_level == 2 and !current_user.unit.is_facility_management_unit
        @fixed_asset_infos = FixedAssetInfo.where(manage_unit_id: current_user.unit_id).order(:asset_no)
      end  
    end     
# binding.pry        
    @fixed_asset_infos_grid = initialize_grid(@fixed_asset_infos,
      :name => 'fixed_asset_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'fixed_asset_infos')

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
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"

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
            catalog_code_index = title_row.index("资产类别编号")
            relevant_department_index = title_row.index("归口管理部门")
            use_at_index = title_row.index("启用日期")
            amount_index = title_row.index("数量")
            sum_index = title_row.index("原值")
            unit_name_index = title_row.index("使用部门")
            location_index = title_row.index("[存放地点]")
            user_index = title_row.index("资产使用人")
            accounting_department_index = title_row.index("核算部门")
            
            
            8.upto(instance.last_row) do |line|
              # binding.pry
              rowarr = instance.row(line)
              if (rowarr[0].blank? and rowarr[1].blank?) or rowarr[0].eql?"合计"
                break
              end
              sn = rowarr[sn_index].blank? ? "" : rowarr[sn_index].to_s.split('.0')[0][0,rowarr[sn_index].to_s.split('.0')[0].length-1]
              asset_name = rowarr[asset_name_index].blank? ? "" : rowarr[asset_name_index].to_s
              asset_no = rowarr[asset_no_index].blank? ? "" : rowarr[asset_no_index].to_s.split('.0')[0]
              catalog_name = rowarr[catalog_name_index].blank? ? "" : rowarr[catalog_name_index].to_s
              catalog_code = rowarr[catalog_code_index].blank? ? "" : rowarr[catalog_code_index].to_s.split('.0')[0]
              relevant_department =rowarr[relevant_department_index].blank? ? "" : to_string(rowarr[relevant_department_index])
              # buy_at = rowarr[6].blank? ? nil : DateTime.parse(rowarr[6].to_s).strftime('%Y-%m-%d')
              use_at = rowarr[use_at_index].blank? ? nil : DateTime.parse(rowarr[use_at_index].to_s).strftime('%Y-%m-%d')
              # measurement_unit = to_string(rowarr[8])
              amount = rowarr[amount_index].blank? ? 0 : rowarr[amount_index].to_i
              sum = rowarr[sum_index].blank? ? 0.0 : rowarr[sum_index].to_f
              unit_name = rowarr[unit_name_index].blank? ? "" : to_string(rowarr[unit_name_index])
              # branch = to_string(rowarr[12])
              location = rowarr[location_index].blank? ? "" : to_string(rowarr[location_index])
              user = rowarr[user_index].blank? ? "" : to_string(rowarr[user_index])
              # change_log = to_string(rowarr[15])
              accounting_department = rowarr[accounting_department_index].blank? ? "" : to_string(rowarr[accounting_department_index])

              if asset_name.blank?
                txt = "缺少资产名称"
                sheet_error << (rowarr << txt)
                next
              end
              if asset_no.blank?
                txt = "缺少资产编号"
                sheet_error << (rowarr << txt)
                next
              end
              if catalog_code.blank?
                txt = "缺少类别目录"
                sheet_error << (rowarr << txt)
                next
              end
              catalog = FixedAssetCatalog.find_by(code:catalog_code,name:catalog_name)
              catalog ||= FixedAssetCatalog.find_by(code:catalog_code)
              if catalog.blank?
                txt = "类别目录不存在"
                sheet_error << (rowarr << txt)
                next
              end
              if unit_name.blank?
                txt = "缺少使用部门"
                sheet_error << (rowarr << txt)
                next
              end
              unit = Unit.where("name like ?", "%#{unit_name}%").first
              if unit.blank?
                txt = "使用部门不存在"
                sheet_error << (rowarr << txt)
                next
              end

              if !relevant_department.blank?
                relevant_department = Unit.where("name like ? and unit_level = ? and is_facility_management_unit = ?", "%#{relevant_department}%", 2, true).first
                if relevant_department.blank?
                  txt = "归口管理部门不存在"
                  sheet_error << (rowarr << txt)
                  next
                end
              end

              ori_info = FixedAssetInfo.find_by(asset_no:asset_no)

              if !ori_info.blank?
                ori_info.update!(relevant_unit_id: relevant_department.id)
                ori_infos.delete(asset_no)
              else
                FixedAssetInfo.create!(sn: sn, asset_name: asset_name, asset_no: asset_no, fixed_asset_catalog_id: catalog.id, relevant_unit_id: relevant_department.id, use_at:use_at, amount:amount, sum:sum, unit_id: unit.id, location:location, user:user, status:"in_use", print_times:0, manage_unit_id: current_user.unit_id, accounting_department: accounting_department)
              end
            end

            if !ori_infos.blank?
              ori_infos.each do |key,value|
                FixedAssetInfo.find_by(asset_no:key).update(status:"discard")
              end
            end

            if !sheet_error.blank?
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message

            if !sheet_error.blank?
              send_data(exporterrorfixed_asset_infos_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Fixed_Asset_Infos_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to :action => 'index'
            end

          rescue Exception => e
            flash[:alert] = e.message
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
    sheet1.row(0).concat title_row
    size = obj.first.size 
    count_row = 1
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
