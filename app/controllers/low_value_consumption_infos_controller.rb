class LowValueConsumptionInfosController < ApplicationController
  load_and_authorize_resource
  # attr_reader :records

  def index
    if current_user.unit.blank?
      @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "in_use").order(:relevant_unit_id, :manage_unit_id, :asset_no)
    else
      if current_user.unit.unit_level == 1
        @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "in_use").order(:relevant_unit_id, :manage_unit_id, :asset_no)
      elsif current_user.unit.is_facility_management_unit
        @low_value_consumption_infos = LowValueConsumptionInfo.where(relevant_unit_id: current_user.unit_id, status: "in_use").order(:manage_unit_id, :asset_no)
      elsif current_user.unit.unit_level == 2
        @low_value_consumption_infos = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "in_use").order(:asset_no)
      end
    end

    @low_value_consumption_infos_grid = initialize_grid(@low_value_consumption_infos,
      :name => 'low_value_consumption_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_infos')


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
    if current_user.unit.blank?
      @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "discard").order(:relevant_unit_id, :manage_unit_id, :asset_no)
    else
      if current_user.unit.unit_level == 1
        @low_value_consumption_infos = LowValueConsumptionInfo.where(status: "discard").order(:relevant_unit_id, :manage_unit_id, :asset_no)
      elsif current_user.unit.is_facility_management_unit
        @low_value_consumption_infos = LowValueConsumptionInfo.where(relevant_unit_id: current_user.unit_id, status: "discard").order(:manage_unit_id, :asset_no)
      elsif current_user.unit.unit_level == 2
        @low_value_consumption_infos = LowValueConsumptionInfo.where(manage_unit_id: current_user.unit_id, status: "discard").order(:asset_no)
      end
    end
    
    @low_value_consumption_infos_grid = initialize_grid(@low_value_consumption_infos,
      :name => 'discard_low_value_consumption_infos',
      :enable_export_to_csv => true,
      :csv_file_name => 'low_value_consumption_infos')
  end

  def show
  end

  def new
    # @low_value_consumption_info = LowValueConsumptionInfo.new
  end

  def edit
    @relename=Unit.find_by(id: @low_value_consumption_info.relevant_unit_id).try(:name)
    @usename = Unit.find_by(id: @low_value_consumption_info.use_unit_id).try(:name)
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
      low_value_consumption_inventory_details = LowValueConsumptionInventoryDetail.joins(:low_value_consumption_inventory).where("lvc_inventory_details.low_value_consumption_info_id = ? and lvc_inventories.status = ?", @low_value_consumption_info.id, "doing").order("lvc_inventories.start_time desc")     
      
      if !low_value_consumption_inventory_details.blank?
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
          @low_value_consumption_info.branch = params[:branch]
          @low_value_consumption_info.location = params[:location]
          @low_value_consumption_info.user = params[:user]
          @low_value_consumption_info.relevant_unit_id = params[:low_value_consumption_info][:relevant_unit_id]
          @low_value_consumption_info.use_unit_id = params[:low_value_consumption_info][:use_unit_id]
          @low_value_consumption_info.update log: (@low_value_consumption_info.log.blank? ? "" : @low_value_consumption_info.log) + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + " " + current_user.try(:unit).try(:name) + " " + current_user.name + " " +"低值易耗品信息批量修改" + ","
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

            short_relevant_departments = Unit.where(is_facility_management_unit: true).group(:desc).size
            short_relevant_departments.each do |key, value|
              short_relevant_departments[key] = Unit.find_by(desc: key).id
            end
           
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"
            catalog_code = ""

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
            
            
            8.upto(instance.last_row) do |line|
              # binding.pry
              rowarr = instance.row(line)
              if (rowarr[0].blank? and rowarr[1].blank?) or rowarr[0].eql?"合计"
                break
              end
              asset_name = rowarr[asset_name_index].blank? ? "" : rowarr[asset_name_index].to_s
              catalog_name = rowarr[catalog_name_index].blank? ? "" : rowarr[catalog_name_index].to_s.split(".").last.strip
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
              desc1 = rowarr[desc1_index].blank? ? "" : to_string(rowarr[desc1_index])
              use_years = rowarr[use_years_index].blank? ? "" : to_string(rowarr[use_years_index])
              brand_model = rowarr[brand_model_index].blank? ? "" : to_string(rowarr[brand_model_index])
              

              if asset_name.blank?
                txt = "缺少资产名称"
                sheet_error << (rowarr << txt)
                next
              end
              if catalog_name.blank?
                txt = "缺少类别目录"
                sheet_error << (rowarr << txt)
                next
              end
              
              if !catalogs.has_key?catalog_name
                txt = "类别目录不存在"
                sheet_error << (rowarr << txt)
                next
              end
              if unit_name.blank?
                txt = "缺少使用部门"
                sheet_error << (rowarr << txt)
                next
              end
              if !use_departments.has_key?unit_name
                txt = "使用部门不存在"
                sheet_error << (rowarr << txt)
                next
              end

              if !relevant_department.blank?
                if !relevant_departments.has_key?relevant_department and !short_relevant_departments.has_key?relevant_department
                  txt = "归口管理部门不存在"
                  sheet_error << (rowarr << txt)
                  next
                end
              end

              if !amount.is_a?(Integer) or amount <= 0
                txt = "请填写正确数量"
                sheet_error << (rowarr << txt)
                next
              end
              
              while amount>0
                lvc_info = LowValueConsumptionInfo.create!(asset_name: asset_name, lvc_catalog_id: catalogs[catalog_name], relevant_unit_id: relevant_departments[relevant_department].blank? ? short_relevant_departments[relevant_department] : relevant_departments[relevant_department], use_at:use_at, sum:sum, use_unit_id: use_departments[unit_name], location: location, user: user, status: "in_use", print_times: 0, manage_unit_id: current_user.unit_id, desc1: desc1, use_years: use_years, brand_model: brand_model)
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
            flash[:alert] = e.message
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
        params["low_value_consumption_infos"]["selected"].each do |id|
          LowValueConsumptionInfo.find(id.to_i).destroy
        end
        flash[:notice] = "批量删除成功"
      end
    end
    redirect_to low_value_consumption_infos_path
  end

  def discard
    # binding.pry
    ActiveRecord::Base.transaction do
      if !params["low_value_consumption_infos"].blank? and !params["low_value_consumption_infos"]["selected"].blank?
        lvc_discard = LvcDiscard.create name: "报废单#{Time.now.strftime("%Y%m%d")}", status: "checking", create_user_id: current_user.id, create_unit_id: current_user.unit_id

        params["low_value_consumption_infos"]["selected"].each do |id|
          lvc_discard.lvc_discard_details.create low_value_consumption_info_id: id.to_i
        end
        flash[:notice] = "报废单已生成"
      end
    end
    redirect_to lvc_discards_path
  end


  private
    def set_low_value_consumption_info
      @low_value_consumption_info = LowValueConsumptionInfo.find(params[:id])
    end

    def low_value_consumption_info_params
      params.require(:low_value_consumption_info).permit(:asset_name, :asset_no, :fixed_asset_catalog_id, :relevant_unit_id, :buy_at, :use_at, :measurement_unit, :sum, :use_unit_id, :branch, :location, :user, :brand_model, :batch_no, :manage_unit_id)
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
