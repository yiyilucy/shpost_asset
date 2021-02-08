class LowValueConsumptionInfosController < ApplicationController
  load_and_authorize_resource
  # attr_reader :records

  def index
    # if current_user.unit.blank?
    #   @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "in_use")
    # else
    #   if current_user.unit.unit_level == 1
    #     @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "in_use")
    #   elsif current_user.unit.is_facility_management_unit
    #     @low_value_consumption_infos = LowValueConsumptionInfo.where("(relevant_unit_id = ? or use_unit_id = ?) and status = ?", current_user.unit_id, current_user.unit_id, "in_use")
    #   elsif current_user.unit.unit_level == 2
    #     @low_value_consumption_infos = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use")
    #   elsif current_user.unit.unit_level == 3 && !current_user.unit.is_facility_management_unit 
    #     @low_value_consumption_infos = LowValueConsumptionInfo.where("(use_unit_id = ? or use_unit_id in (?)) and status = ?", current_user.unit_id, current_user.unit.children.map{|x| x.id}, "in_use")
    #   end
    # end
    
    # if !params[:catalog4].blank?
    #   @low_value_consumption_infos = @low_value_consumption_infos.where(lvc_catalog_id: params[:catalog4].to_i)
    # elsif !params[:catalog3].blank?
    #   catalog3_code = LowValueConsumptionCatalog.find(params[:catalog3].to_i).code
    #   @low_value_consumption_infos = @low_value_consumption_infos.joins(:low_value_consumption_catalog).where("low_value_consumption_catalogs.code like ?", "#{catalog3_code}%" )  
    # elsif !params[:catalog2].blank?
    #   catalog2_code = LowValueConsumptionCatalog.find(params[:catalog2].to_i).code
    #   @low_value_consumption_infos = @low_value_consumption_infos.joins(:low_value_consumption_catalog).where("low_value_consumption_catalogs.code like ?", "#{catalog2_code}%" )  
    # elsif !params[:catalog].blank? && !params[:catalog][:catalog1].blank?
    #   catalog1_code = LowValueConsumptionCatalog.find(params[:catalog][:catalog1].to_i).code
    #   @low_value_consumption_infos = @low_value_consumption_infos.joins(:low_value_consumption_catalog).where("low_value_consumption_catalogs.code like ?", "#{catalog1_code}%" )  
    # end
    catalog1 = nil
    
    if !params[:catalog].blank? && !params[:catalog][:catalog1].blank?
      catalog1 = params[:catalog][:catalog1]
    end

    @low_value_consumption_infos = LowValueConsumptionInfo.get_in_use_infos(LowValueConsumptionInfo, current_user, params[:catalog4], params[:catalog3], params[:catalog2], catalog1)
    
    @low_value_consumption_infos_grid = initialize_grid(@low_value_consumption_infos,
      :name => 'low_value_consumption_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_infos', 
      :per_page => params[:page_size])


    # @records = []

    # binding.pry

    # @low_value_consumption_infos_grid.with_paginated_resultset do |records|
    #   records.each do |rec| 
    #     # binding.pry
    #     @records << rec
    #   end
    # end
    export_grid_if_requested
  end

  def discard_index
    @low_value_consumption_infos = LowValueConsumptionInfo.get_discard_infos(LowValueConsumptionInfo, current_user)
    
    @low_value_consumption_infos_grid = initialize_grid(@low_value_consumption_infos,
      :name => 'discard_low_value_consumption_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_infos')
    export_grid_if_requested
  end

  def show
  end

  def new
    # @low_value_consumption_info = LowValueConsumptionInfo.new
  end

  def edit
    @relename=Unit.find_by(id: @low_value_consumption_info.relevant_unit_id).try(:name)
    @usename = Unit.find_by(id: @low_value_consumption_info.use_unit_id).try(:name)
    @low_value_consumption_catalog = LowValueConsumptionCatalog.find_by(id: @low_value_consumption_info.lvc_catalog_id).try(:name)
  end

  def create
    respond_to do |format|
      if @low_value_consumption_info.save
        format.html { redirect_to @low_value_consumption_infos, notice: I18n.t('controller.create_success_notice', model: '低值易耗品信息') }
        format.json { render action: 'show', status: :created, location: @low_value_consumption_info }
      else
        format.html { render action: 'new' }
        format.json { render json: @low_value_consumption_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @low_value_consumption_info.update(low_value_consumption_info_params)
        if @low_value_consumption_info.status.eql?"in_use"
          @low_value_consumption_info.update log: (@low_value_consumption_info.log.blank? ? "" : @low_value_consumption_info.log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"低值易耗品信息修改" + ","
        end
        format.html { redirect_to @low_value_consumption_info, notice: I18n.t('controller.update_success_notice', model: '低值易耗品信息')}
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
      format.html { redirect_to low_value_consumption_infos_url }
      format.json { head :no_content }
    end
  end

  def print
    if params[:low_value_consumption_infos] && params[:low_value_consumption_infos][:selected]
      @selected = params[:low_value_consumption_infos][:selected]
      @result = []
      
      until @selected.blank? do 
        @result = @result + LowValueConsumptionInfo.where(id:@selected.pop(1000))
      end

      # @result.sort_by{|x| "#{x.use_unit_id.to_s} #{x.lvc_catalog_id.to_s}"}
    else
      flash[:alert] = "请勾选需要打印的低值易耗品"
      respond_to do |format|
        format.html { redirect_to low_value_consumption_infos_url }
        format.json { head :no_content }
      end
    end

    # binding.pry
  end

  def to_scan
    @low_value_consumption_info = nil
    
    if !params.blank? and !params[:id].blank?
      @low_value_consumption_info = LowValueConsumptionInfo.find(params[:id].to_i)
      low_value_consumption_inventory_details = LowValueConsumptionInventoryDetail.joins(:low_value_consumption_inventory).where("lvc_inventory_details.low_value_consumption_info_id = ? and lvc_inventories.status = ? and lvc_inventory_details.inventory_status = ?", @low_value_consumption_info.id, "doing", "waiting").order("lvc_inventories.start_time")     

      if !low_value_consumption_inventory_details.blank? && (can? :scan, LowValueConsumptionInventoryDetail)
        @low_value_consumption_inventory_detail = low_value_consumption_inventory_details.first
        @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory

        respond_to do |format|
          format.html { redirect_to scan_low_value_consumption_inventory_detail_path(@low_value_consumption_inventory_detail) }
          format.json { head :no_content }
        end
      end
    end
  end

  def batch_edit
    @relename = ''
    @usename = ''
    @low_value_consumption_catalog = ''
    @lvcids = ""
# binding.pry
 
    if !params["low_value_consumption_infos"].blank? and !params["low_value_consumption_infos"]["selected"].blank?
      @lvcids = params["low_value_consumption_infos"]["selected"].compact.join(",")
      @low_value_consumption_info = LowValueConsumptionInfo.find(params["low_value_consumption_infos"]["selected"].first.to_i)
    
      if !@low_value_consumption_info.relevant_unit_id.blank?
        @relename = Unit.find_by(id: @low_value_consumption_info.relevant_unit_id).try(:name)
      end
      if !@low_value_consumption_info.use_unit_id.blank?
        @usename = Unit.find_by(id: @low_value_consumption_info.use_unit_id).try(:name)
      end
      @low_value_consumption_catalog = LowValueConsumptionCatalog.find_by(id: @low_value_consumption_info.lvc_catalog_id).try(:name)
    else
      respond_to do |format|
          format.html { redirect_to low_value_consumption_infos_url, alert: "请勾选低值易耗品" }
          format.json { head :no_content }
      end
    end
  end

  def batch_update
    ActiveRecord::Base.transaction do
      # binding.pry
      if !params[:lvcids].blank?
        params[:lvcids].split(",").map(&:to_i).each do |id|
          @low_value_consumption_info = LowValueConsumptionInfo.find_by(id:id.to_i)
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
          @low_value_consumption_info.update log: (@low_value_consumption_info.log.blank? ? "" : @low_value_consumption_info.log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"低值易耗品信息批量修改" + ","
          @low_value_consumption_info.is_rent = params[:checkbox][:is_rent].eql?"1"
          if !params[:desc1].blank? && !params[:desc1].strip.blank?
            @low_value_consumption_info.desc1 = params[:desc1]
          end
          if !params[:low_value_consumption_info][:lvc_catalog_id].blank?
            @low_value_consumption_info.lvc_catalog_id = params[:low_value_consumption_info][:lvc_catalog_id]
          end
          @low_value_consumption_info.save
        end
        flash[:notice] = "批量修改成功"
        redirect_to low_value_consumption_infos_path
      else
        flash[:alert] = "请勾选低值易耗品"
        redirect_to low_value_consumption_infos_path
      end
    end
  end

  # def discard
  #   @low_value_consumption_info.update status: "discard", discard_at: Time.now, log: (@low_value_consumption_info.log.blank? ? "" : @low_value_consumption_info.log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"低值易耗品信息报废" + ","

  #   respond_to do |format|
  #     format.html { redirect_to low_value_consumption_infos_url }
  #     format.json { head :no_content }
  #   end
  # end

  def low_value_consumption_info_import
    unless request.get?
      if file = upload_low_value_consumption_info(params[:file]['file'])       
        ActiveRecord::Base.transaction do
          begin
            catalogs = LowValueConsumptionCatalog.all.group(:name).size
            catalogs.each do |key, value|
              catalogs[key] = LowValueConsumptionCatalog.find_by(name: key).id
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

            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first
            title_row = instance.row(7)
            asset_name_index = title_row.index("资产名称")
            catalog_name_index = title_row.index("资产类别名称")
            relevant_department_index = title_row.index("归口管理部门")
            use_at_index = title_row.index("启用日期")
            amount_index = title_row.index("数量")
            sum_index = title_row.index("原值")
            unit_name_index = title_row.index("使用部门")
            location_index = title_row.index("[存放地点]")
            user_index = title_row.index("资产使用人")
            accounting_department_index = title_row.index("核算部门")
            desc1_index = title_row.index("使用单位")
            use_years_index = title_row.index("使用年限")
            brand_model_index = title_row.index("结构/型号")
            is_rent_index = title_row.index("是否租赁")
            
            
            8.upto(instance.last_row) do |line|
              # binding.pry
              current_line = line
              rowarr = instance.row(line)
              if (rowarr[0].blank? and rowarr[1].blank?) or rowarr[0].eql?"合计"
                break
              end
              asset_name = rowarr[asset_name_index].blank? ? "" : rowarr[asset_name_index].to_s
              catalog_name = rowarr[catalog_name_index].blank? ? "" : rowarr[catalog_name_index].to_s.split(".").last.strip
              relevant_department =rowarr[relevant_department_index].blank? ? "" : to_string(rowarr[relevant_department_index])
              # buy_at = rowarr[6].blank? ? nil : DateTime.parse(rowarr[6].to_s).strftime('%Y-%m-%d')
              use_at = rowarr[use_at_index].blank? ? nil : DateTime.parse(rowarr[use_at_index].to_s.split(".0")[0]).strftime('%Y-%m-%d')
              # measurement_unit = to_string(rowarr[8])
              amount = rowarr[amount_index].blank? ? 0 : rowarr[amount_index].to_i
              sum = rowarr[sum_index].blank? ? 0.0 : rowarr[sum_index].to_f
              unit_name = rowarr[unit_name_index].blank? ? "" : to_string(rowarr[unit_name_index])
              # branch = to_string(rowarr[12])
              location = rowarr[location_index].blank? ? "" : to_string(rowarr[location_index])
              user = rowarr[user_index].blank? ? "" : to_string(rowarr[user_index])
              # change_log = to_string(rowarr[15])
              accounting_department = rowarr[accounting_department_index].blank? ? "" : to_string(rowarr[accounting_department_index])
              desc1 = rowarr[desc1_index].blank? ? "" : to_string(rowarr[desc1_index])
              use_years = rowarr[use_years_index].blank? ? "" : rowarr[use_years_index].to_s.split(".0")[0]
              brand_model = rowarr[brand_model_index].blank? ? "" : to_string(rowarr[brand_model_index])
              is_rent = rowarr[is_rent_index].blank? ? false : ((to_string(rowarr[is_rent_index]).eql?"是") ? true : false)
              
              if asset_name.blank?
                txt = "缺少资产名称_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback         
              end
              if catalog_name.blank?
                txt = "缺少类别目录_"
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
              if unit_name.blank?
                txt = "缺少使用部门_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end
              if !use_departments.has_key?unit_name
                txt = "使用部门不存在_"
                sheet_error << (rowarr << txt)
                raise txt
                raise ActiveRecord::Rollback 
              end

              if !relevant_department.blank?
                if !relevant_departments.has_key?relevant_department and !short_relevant_departments.has_key?relevant_department
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
              
              while amount>0
                lvc_info = LowValueConsumptionInfo.create!(asset_name: asset_name, lvc_catalog_id: catalogs[catalog_name], relevant_unit_id: relevant_departments[relevant_department].blank? ? short_relevant_departments[relevant_department] : relevant_departments[relevant_department], use_at:use_at, sum:sum, use_unit_id: use_departments[unit_name], location: location, use_user: user, status: "in_use", print_times: 0, manage_unit_id: current_user.unit_id, desc1: desc1, use_years: use_years, brand_model: brand_model, is_rent: is_rent)
                lvc_info.update asset_no: Sequence.generate_asset_no(lvc_info,lvc_info.use_at)

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
              redirect_to low_value_consumption_infos_path
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

  def exporterrorlow_value_consumption_infos_xls_content_for(obj,title_row)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Low_Value_Consumption_Infos"  

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

  def batch_destroy
    # binding.pry
    ActiveRecord::Base.transaction do
      if !params["low_value_consumption_infos"].blank? and !params["low_value_consumption_infos"]["selected"].blank?
        LowValueConsumptionInfo.batch_destroy(LowValueConsumptionInfo, params["low_value_consumption_infos"]["selected"])
        
        flash[:notice] = "批量删除成功"
      end
    end
    redirect_to low_value_consumption_infos_path
  end

  def discard
    ActiveRecord::Base.transaction do
      if !params["low_value_consumption_infos"].blank? and !params["low_value_consumption_infos"]["selected"].blank?
        LvcDiscard.do_discard(params[:atype], params["low_value_consumption_infos"]["selected"], current_user)
        
        flash[:notice] = "报废单已生成"
      end
    end
    redirect_to lvc_discards_path(atype: params[:atype])
  end

  def low_value_consumption_report
    if current_user.unit.unit_level == 1
      @sums = LowValueConsumptionInfo.where(status: "in_use").group(:manage_unit_id).order(:manage_unit_id).sum(:sum)
      @counts = LowValueConsumptionInfo.where(status: "in_use").group(:manage_unit_id).order(:manage_unit_id).count
      @total_sum = LowValueConsumptionInfo.where(status: "in_use").sum(:sum)
      @total_count = LowValueConsumptionInfo.where(status: "in_use").size
      @units = Unit.where(unit_level: 2).select(:id, :name)
    elsif (current_user.unit.unit_level == 3) && current_user.unit.is_facility_management_unit
      @sums = LowValueConsumptionInfo.where(relevant_unit_id: current_user.unit_id, status: "in_use").group(:manage_unit_id).order(:manage_unit_id).sum(:sum)
      @counts = LowValueConsumptionInfo.where(relevant_unit_id: current_user.unit_id, status: "in_use").group(:manage_unit_id).order(:manage_unit_id).count
      @total_sum = LowValueConsumptionInfo.where(relevant_unit_id: current_user.unit_id, status: "in_use").sum(:sum)
      @total_count = LowValueConsumptionInfo.where(relevant_unit_id: current_user.unit_id, status: "in_use").size
      @units = Unit.where(unit_level: 2).select(:id, :name)
    elsif current_user.unit.unit_level == 2
      @sums = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").group(:use_unit_id).order(:use_unit_id).sum(:sum)
      @counts = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").group(:use_unit_id).order(:use_unit_id).count
      @total_sum = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").sum(:sum)
      @total_count = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").size
      @units = Unit.where("units.id = ? or units.parent_id = ? or units.parent_id in (?)", current_user.unit_id, current_user.unit_id, current_user.unit.children.map{|x| x.id}).select(:id, :name)
    end
  end

  def low_value_consumption_report_export
    if current_user.unit.unit_level == 1
      @sums = LowValueConsumptionInfo.where(status: "in_use").group(:manage_unit_id).order(:manage_unit_id).sum(:sum)
      @counts = LowValueConsumptionInfo.where(status: "in_use").group(:manage_unit_id).order(:manage_unit_id).count
      @total_sum = LowValueConsumptionInfo.where(status: "in_use").sum(:sum)
      @total_count = LowValueConsumptionInfo.where(status: "in_use").size
      @units = Unit.where(unit_level: 2).select(:id, :name)
    elsif current_user.unit.unit_level == 2
      @sums = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").group(:use_unit_id).order(:use_unit_id).sum(:sum)
      @counts = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").group(:use_unit_id).order(:use_unit_id).count
      @total_sum = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").sum(:sum)
      @total_count = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").size
      @units = Unit.where("units.id = ? or units.parent_id = ? or units.parent_id in (?)", current_user.unit_id, current_user.unit_id, current_user.unit.children.map{|x| x.id}).select(:id, :name)
    end
    send_data(low_value_consumption_report_xls_content_for(@sums,@counts,@total_sum,@total_count,@units), :type => "text/excel;charset=utf-8; header=present", :filename => "low_value_consumption_report_#{Time.now.strftime("%Y%m%d")}.xls")  
  end

  def low_value_consumption_report_xls_content_for(sums,counts,total_sum,total_count,units)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "low_value_consumption_report"  
    
    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    sheet1.row(0).default_format = blue  

    sheet1.row(0).concat %w{单位名称 数量 总值}
    count_row = 1
    @units.each do |x|
      sheet1[count_row,0]=x.name
      sheet1[count_row,1]=@counts[x.id].blank? ? 0 : @counts[x.id]
      sheet1[count_row,2]=@sums[x.id].blank? ? 0 : @sums[x.id]
      count_row += 1
    end  

    sheet1[count_row,0]="合计"
    sheet1[count_row,1]=total_count
    sheet1[count_row,2]=total_sum
  
    book.write xls_report  
    xls_report.string  
  end

  def lvc_report
    # @manage_unit_id = nil
    # if !params[:lvc_report].blank? && !params[:lvc_report][:manage_unit_id].blank?
    #   @manage_unit_id = params[:lvc_report][:manage_unit_id].to_i
    # end
# binding.pry
    unless request.get?
      if !params[:year].blank? && !params[:month].blank?
        @year = params[:year]
        @month = params[:month]
        cal_date = (@year+@month.rjust(2, '0')+"01").to_datetime.end_of_month
        
        if current_user.unit.unit_level == 1
          # if @manage_unit_id.blank?
            @results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where("low_value_consumption_infos.use_at <= ? and (low_value_consumption_infos.discard_at is null or low_value_consumption_infos.discard_at > ?)", cal_date, cal_date).where("length(low_value_consumption_catalogs.code)=8")
          # else
          #   results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where(status: "in_use").where("length(low_value_consumption_catalogs.code)=8").where(manage_unit_id: @manage_unit_id)
          # end
          @sums = @results.group(:lvc_catalog_id, :manage_unit_id).order(:lvc_catalog_id, :manage_unit_id).sum(:sum)
          @counts = @results.group(:lvc_catalog_id, :manage_unit_id).order(:lvc_catalog_id, :manage_unit_id).count
          @total_sum = @results.sum(:sum)
          @total_count = @results.count
        elsif (current_user.unit.unit_level == 3) && current_user.unit.is_facility_management_unit
          # if @manage_unit_id.blank?
            @results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where(relevant_unit_id: current_user.unit_id).where("low_value_consumption_infos.use_at < ? and (low_value_consumption_infos.discard_at is null or low_value_consumption_infos.discard_at >= ?)", cal_date, cal_date).where("length(low_value_consumption_catalogs.code)=8")
          # else
          #   results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where(status: "in_use", relevant_unit_id: current_user.unit_id).where("length(low_value_consumption_catalogs.code)=8").where(manage_unit_id: @manage_unit_id)
          # end
          @sums = @results.group(:lvc_catalog_id, :manage_unit_id).order(:lvc_catalog_id, :manage_unit_id).sum(:sum)
          @counts = @results.group(:lvc_catalog_id, :manage_unit_id).order(:lvc_catalog_id, :manage_unit_id).count
          @total_sum = @results.sum(:sum)
          @total_count = @results.count  
        elsif current_user.unit.unit_level == 2
          @results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where(manage_unit_id: current_user.unit_id).where("low_value_consumption_infos.use_at < ? and (low_value_consumption_infos.discard_at is null or low_value_consumption_infos.discard_at >= ?)", cal_date, cal_date).where("length(low_value_consumption_catalogs.code)=8")
          @sums = @results.group(:lvc_catalog_id, :use_unit_id).order(:lvc_catalog_id, :use_unit_id).sum(:sum)
          @counts = @results.group(:lvc_catalog_id, :use_unit_id).order(:lvc_catalog_id, :use_unit_id).count
          @total_sum = @results.sum(:sum)
          @total_count = @results.count
        end
      else
        flash[:alert] = "请先选择统计年月"
        redirect_to lvc_report_low_value_consumption_infos_url and return
      end
    end
  end

  def lvc_report_export
    # @manage_unit_id = nil
    # if !params[:lvc_report].blank? && !params[:lvc_report][:manage_unit_id].blank?
    #   @manage_unit_id = params[:lvc_report][:manage_unit_id].to_i
    # elsif !params[:munit_id].blank?
    #   @manage_unit_id = params[:munit_id].to_i
    # end
    unless request.get?
      if !params[:year].blank? && !params[:month].blank?
        @year = params[:year]
        @month = params[:month]
        cal_date = (@year+@month.rjust(2, '0')+"01").to_datetime.end_of_month

        if current_user.unit.unit_level == 1
          # if @manage_unit_id.blank?
            results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where("low_value_consumption_infos.use_at <= ? and (low_value_consumption_infos.discard_at is null or low_value_consumption_infos.discard_at > ?)", cal_date, cal_date).where("length(low_value_consumption_catalogs.code)=8")
          # else
          #   results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where(status: "in_use").where("length(low_value_consumption_catalogs.code)=8").where(manage_unit_id: @manage_unit_id)
          # end
          @sums = results.group(:lvc_catalog_id, :manage_unit_id).order(:lvc_catalog_id, :manage_unit_id).sum(:sum)
          @counts = results.group(:lvc_catalog_id, :manage_unit_id).order(:lvc_catalog_id, :manage_unit_id).count
          @total_sum = results.sum(:sum)
          @total_count = results.count
        elsif (current_user.unit.unit_level == 3) && current_user.unit.is_facility_management_unit
          # if @manage_unit_id.blank?
            results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where(relevant_unit_id: current_user.unit_id).where("low_value_consumption_infos.use_at < ? and (low_value_consumption_infos.discard_at is null or low_value_consumption_infos.discard_at >= ?)", cal_date, cal_date).where("length(low_value_consumption_catalogs.code)=8")
          # else
          #   results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where(status: "in_use", relevant_unit_id: current_user.unit_id).where("length(low_value_consumption_catalogs.code)=8").where(manage_unit_id: @manage_unit_id)
          # end
          @sums = results.group(:lvc_catalog_id, :manage_unit_id).order(:lvc_catalog_id, :manage_unit_id).sum(:sum)
          @counts = results.group(:lvc_catalog_id, :manage_unit_id).order(:lvc_catalog_id, :manage_unit_id).count
          @total_sum = results.sum(:sum)
          @total_count = results.count  
        elsif current_user.unit.unit_level == 2
          results = LowValueConsumptionInfo.joins(:low_value_consumption_catalog).where(manage_unit_id: current_user.unit_id).where("low_value_consumption_infos.use_at < ? and (low_value_consumption_infos.discard_at is null or low_value_consumption_infos.discard_at >= ?)", cal_date, cal_date).where("length(low_value_consumption_catalogs.code)=8")
          @sums = results.group(:lvc_catalog_id, :use_unit_id).order(:lvc_catalog_id, :use_unit_id).sum(:sum)
          @counts = results.group(:lvc_catalog_id, :use_unit_id).order(:lvc_catalog_id, :use_unit_id).count
          @total_sum = results.sum(:sum)
          @total_count = results.count
        end
      
        send_data(lvc_report_xls_content_for(@sums,@counts,@total_sum,@total_count,@year,@month), :type => "text/excel;charset=utf-8; header=present", :filename => "lvc_report_#{Time.now.strftime("%Y%m%d")}.xls")  
      else
        flash[:alert] = "请先选择统计年月"
        redirect_to lvc_report_low_value_consumption_infos_url and return
      end
    end  
  end

  def lvc_report_xls_content_for(sums,counts,total_sum,total_count,year,month)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "low_value_consumption_report"  
    
    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10 
    title = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center, :weight => :bold
    body = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center
 
    sheet1.row(0).default_format = blue  

    sheet1.row(0).concat %w{会计期间 资产类别 资产一级类别 资产二级类别 资产三级类别 资产四级类别 公司 公司 原值}
    0.upto(8) do |i|
      sheet1.row(0).set_format(i, title)
    end
    count_row = 1

    if !sums.blank?
      sums.each do |k, v|
        code = LowValueConsumptionCatalog.find(k[0]).code
        sheet1[count_row,0]=(year+month.rjust(2, '0')+"01").to_datetime.strftime("%Y-%m")
        sheet1[count_row,1]=code[0,2]+"."+code[0,4]+"."+code[0,6]+"."+code[0,8]
        sheet1[count_row,2]=LowValueConsumptionCatalog.find_by(code: code[0,2]).try :name
        sheet1[count_row,3]=LowValueConsumptionCatalog.find_by(code: code[0,4]).try :name
        sheet1[count_row,4]=LowValueConsumptionCatalog.find_by(code: code[0,6]).try :name
        sheet1[count_row,5]=LowValueConsumptionCatalog.find_by(code: code[0,8]).try :name
        sheet1[count_row,6]=Unit.find(k[1]).name
        sheet1[count_row,7]=counts[k].blank? ? 0 : counts[k]
        sheet1[count_row,8]=v

        0.upto(8) do |i|
          sheet1.row(count_row).set_format(i, body)
        end

        count_row += 1
      end  

      sheet1[count_row,0]="合计"
      sheet1[count_row,7]=total_count
      sheet1[count_row,8]=total_sum
    end
      
    0.upto(8) do |i|
      sheet1.row(count_row).set_format(i, body)
    end
  
    book.write xls_report  
    xls_report.string  
  end

  def select_catalog2
    # @catalog2s = nil
    # if !params[:catalog1].blank?
    #   code = LowValueConsumptionCatalog.find(params[:catalog1].to_i).code
    #   @catalog2s = LowValueConsumptionCatalog.where("length(code)=4 and code like ?", "#{code}%").order(:code).map{|c| [c.name,c.id]}.insert(0,"")
    # end
    @catalog2s = LowValueConsumptionInfo.select_catalog2(LowValueConsumptionCatalog, params[:catalog1])
    
    respond_to do |format|
      format.js 
    end
  end

  def select_catalog3
   @catalog3s = LowValueConsumptionInfo.select_catalog3(LowValueConsumptionCatalog, params[:catalog2])

    respond_to do |format|
      format.js 
    end
  end

  def select_catalog4
    @catalog4s = LowValueConsumptionInfo.select_catalog4(LowValueConsumptionCatalog, params[:catalog3])

    respond_to do |format|
      format.js 
    end
  end

  def reprint_import
    unless request.get?
      if file = upload_low_value_consumption_info(params[:file]['file'])       
        ActiveRecord::Base.transaction do
          begin
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"
            current_line = 0
            is_error = false
            sheet_error = []

            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first
            title_row = instance.row(1)
            asset_no_index = title_row.index("资产编号").blank? ? 0 : title_row.index("资产编号")
            
            2.upto(instance.last_row) do |line|
              current_line = line
              rowarr = instance.row(line)
              asset_no = rowarr[asset_no_index].blank? ? "" : rowarr[asset_no_index].to_s.split('.0')[0]
              
              ori_info = LowValueConsumptionInfo.find_by(asset_no: asset_no)

              if !ori_info.blank?
                ori_info.update! is_reprint: true
              else
                txt = "资产编号不存在"
                sheet_error << (rowarr << txt)
              end
            end

            if !sheet_error.blank?
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message

            if !sheet_error.blank?
              send_data(exporterrorreprint_infos_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Reprints_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to :action => 'index'
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

  def exporterrorreprint_infos_xls_content_for(obj,title_row)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Reprints"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    red = Spreadsheet::Format.new :color => :red
    sheet1.row(0).default_format = blue 
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

  private
    def set_low_value_consumption_info
      @low_value_consumption_info = LowValueConsumptionInfo.find(params[:id])
    end

    def low_value_consumption_info_params
      params.require(:low_value_consumption_info).permit(:asset_name, :asset_no, :lvc_catalog_id, :relevant_unit_id, :buy_at, :use_at, :measurement_unit, :sum, :use_unit_id, :branch, :location, :use_user, :brand_model, :batch_no, :manage_unit_id, :use_years, :desc1, :is_rent, :is_reprint)
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
