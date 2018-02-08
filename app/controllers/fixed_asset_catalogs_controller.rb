class FixedAssetCatalogsController < ApplicationController
  load_and_authorize_resource

  def index
    # @fixed_asset_catalogs = FixedAssetCatalog.all
    @fixed_asset_catalogs = initialize_grid(@fixed_asset_catalogs,
         :order => 'fixed_asset_catalogs.code',
         :order_direction => 'asc')
  end

  def show
  end

  def new
    # @fixed_asset_catalog = FixedAssetCatalog.new
    # respond_with(@fixed_asset_catalog)
  end

  def edit
  end

  # def create
  #   @fixed_asset_catalog = FixedAssetCatalog.new(fixed_asset_catalog_params)
  #   @fixed_asset_catalog.save
  #   respond_with(@fixed_asset_catalog)
  # end

  # def update
  #   @fixed_asset_catalog.update(fixed_asset_catalog_params)
  #   respond_with(@fixed_asset_catalog)
  # end

  # def destroy
  #   @fixed_asset_catalog.destroy
  #   respond_with(@fixed_asset_catalog)
  # end
  def create
    respond_to do |format|
      if @fixed_asset_catalog.save
        format.html { redirect_to @fixed_asset_catalog, notice: I18n.t('controller.create_success_notice', model: '固定资产信息') }
        format.json { render action: 'show', status: :created, location: @fixed_asset_catalog }
      else
        format.html { render action: 'new' }
        format.json { render json: @fixed_asset_catalog.errors, status: :unprocessable_entity }
      end
    end
  end
  def update
    respond_to do |format|
      if @fixed_asset_catalog.update(fixed_asset_catalog_params)
        
        format.html { redirect_to @fixed_asset_catalog, notice: I18n.t('controller.update_success_notice', model: '固定资产信息')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @fixed_asset_catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @fixed_asset_catalog.destroy
    respond_to do |format|
      format.html { redirect_to fixed_asset_catalogs_url }
      format.json { head :no_content }
    end
  end


  def fixed_asset_catalog_import
    unless request.get?
      if file = upload_fixed_asset_catalog(params[:file]['file'])       
        ActiveRecord::Base.transaction do
          begin
            ori_catalogs = FixedAssetCatalog.group(:code).order(:code).size
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"
            current_line = 0

            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first
            
            2.upto(instance.last_row) do |line|
              current_line = line
              rowarr = instance.row(line)
              code1 = rowarr[0].blank? ? "" : rowarr[0].to_s.split('.0')[0]
              code2 = rowarr[1].blank? ? "" : rowarr[1].to_s.split('.0')[0]
              code3 = rowarr[2].blank? ? "" : rowarr[2].to_s.split('.0')[0]
              code4 = rowarr[3].blank? ? "" : rowarr[3].to_s.split('.0')[0]
              name = to_string(rowarr[4]).strip
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

              ori_catalog = FixedAssetCatalog.find_by(code:code)

              if !ori_catalog.blank?
                ori_catalog.update!(name: name, measurement_unit: measurement_unit, years: years, desc: desc)
                ori_catalogs.delete(code)
              else
                FixedAssetCatalog.create!(code: code, name: name, measurement_unit: measurement_unit, years: years, desc: desc)
              end
            end

            if !ori_catalogs.blank?
              ori_catalogs.each do |key,value|
                if !FixedAssetCatalog.where(code:key).blank? and FixedAssetCatalog.find_by(code:key).fixed_asset_infos.blank?
                  FixedAssetCatalog.find_by(code:key).delete
                end
              end
            end

            if !sheet_error.blank?
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message

            if !sheet_error.blank?
              send_data(exporterrorfixed_asset_catalogs_xls_content_for(sheet_error),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Fixed_Asset_Catalogs_#{Time.now.strftime("%Y%m%d")}.xls")  
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

  def exporterrorfixed_asset_catalogs_xls_content_for(obj)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Fixed_Asset_Catalogs"  

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
    def set_fixed_asset_catalog
      @fixed_asset_catalog = FixedAssetCatalog.find(params[:id])
    end

    def fixed_asset_catalog_params
      params[:fixed_asset_catalog].permit(:code,:name,:measurement_unit,:years,:desc)
    end

    def upload_fixed_asset_catalog(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/fixed_asset_catalog/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end
        file_path
      end
    end
end
