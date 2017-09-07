class LowValueConsumptionCatalogsController < ApplicationController
  load_and_authorize_resource

  def index
    @low_value_consumption_catalogs = initialize_grid(@low_value_consumption_catalogs)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @low_value_consumption_catalog = LowValueConsumptionCatalog.new(low_value_consumption_catalog_params)
    @low_value_consumption_catalog.save
    respond_with(@low_value_consumption_catalog)
  end

  def update
    @low_value_consumption_catalog.update(low_value_consumption_catalog_params)
    respond_with(@low_value_consumption_catalog)
  end

  def destroy
    @low_value_consumption_catalog.destroy
    respond_with(@low_value_consumption_catalog)
  end

  def low_value_consumption_catalog_import
    unless request.get?
      if file = upload_low_value_consumption_catalog(params[:file]['file'])       
        ActiveRecord::Base.transaction do
          begin
            ori_catalogs = LowValueConsumptionCatalog.group(:code).order(:code).size
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
            
            2.upto(instance.last_row) do |line|
              rowarr = instance.row(line)
              code1 = rowarr[0].blank? ? "" : rowarr[0].to_s.split('.0')[0]
              code2 = rowarr[1].blank? ? "" : rowarr[1].to_s.split('.0')[0]
              code3 = rowarr[2].blank? ? "" : rowarr[2].to_s.split('.0')[0]
              code4 = rowarr[3].blank? ? "" : rowarr[3].to_s.split('.0')[0]
              name = to_string(rowarr[4])
              measurement_unit = to_string(rowarr[5])
              years = rowarr[6].blank? ? nil : rowarr[6].to_s.split('.0')[0].to_i
              desc = to_string(rowarr[7])
              # binding.pry
              code = code1+code2+code3+code4
              if code.blank?
                txt = "缺少目录编码"
                sheet_error << (rowarr << txt)
                next
              elsif code.length>8
                txt = "目录编码超过8位"
                sheet_error << (rowarr << txt)
                next
              end

              if name.blank?
                txt = "缺少名称"
                sheet_error << (rowarr << txt)
                next
              end

              ori_catalog = LowValueConsumptionCatalog.find_by(code:code)

              if !ori_catalog.blank?
                ori_catalog.update!(name: name, measurement_unit: measurement_unit, years: years, desc: desc)
                ori_catalogs.delete(code)
              else
                LowValueConsumptionCatalog.create!(code: code, name: name, measurement_unit: measurement_unit, years: years, desc: desc)
              end
            end

            if !ori_catalogs.blank?
              ori_catalogs.each do |key,value|
                LowValueConsumptionCatalog.find_by(code:key).delete
              end
            end

            if !sheet_error.blank?
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message

            if !sheet_error.blank?
              send_data(exporterrorlow_value_consumption_catalogs_xls_content_for(sheet_error),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Low_Value_Consumption_Catalogs_#{Time.now.strftime("%Y%m%d")}.xls")  
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

  def exporterrorlow_value_consumption_catalogs_xls_content_for(obj)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Low_Value_Consumption_Catalogs"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    red = Spreadsheet::Format.new :color => :red
    sheet1.row(0).default_format = blue 
    sheet1.row(0).concat %w{编码1 编码2 编码3 编码4 名称 计量单位 建议使用年限 说明}  
    count_row = 1
    obj.each do |obj|
      sheet1[count_row,0]=obj[0]
      sheet1[count_row,1]=obj[1]
      sheet1[count_row,2]=obj[2]
      sheet1[count_row,3]=obj[3]
      sheet1[count_row,4]=obj[4]
      sheet1[count_row,5]=obj[5]
      sheet1[count_row,6]=obj[6]
      sheet1[count_row,7]=obj[7]
      sheet1[count_row,8]=obj[8]
      
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


  private
    def set_low_value_consumption_catalog
      @low_value_consumption_catalog = LowValueConsumptionCatalog.find(params[:id])
    end

    def low_value_consumption_catalog_params
      params[:low_value_consumption_catalog]
    end

    def upload_low_value_consumption_catalog(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/low_value_consumption_catalog/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end
        file_path
      end
    end
end
