class RentInventoriesController < ApplicationController
  load_and_authorize_resource

  def index
    @is_sample = false
    @rent_inventories = RentInventory.where(create_unit_id: current_user.unit_id, is_sample: false)
    @rent_inventories_grid = initialize_grid(@rent_inventories, order: 'rent_inventories.created_at',
      order_direction: 'desc')
  end

  def show
    respond_with(@rent_inventory)
  end

  def new
    @inventory = RentInventory.new
    if current_user.unit.unit_level == 1
      @units_grid = initialize_grid(Unit.where(unit_level: 2).order(:no), per_page: 1000,:name => 'g1')
      @relevant_departments_grid = initialize_grid(Unit.where(is_facility_management_unit: true).order(:no), per_page: 1000,:name => 'g2')
    elsif current_user.unit.is_facility_management_unit
      @units_grid = initialize_grid(Unit.where(unit_level: 2).order(:no), per_page: 1000,:name => 'g1')
      @relevant_departments_grid = initialize_grid(Unit.where(id: current_user.unit_id), per_page: 1000,:name => 'g2')
    elsif current_user.unit.unit_level == 2
      lv3units = Unit.where(parent_id: current_user.unit_id).select(:id)
      @units_grid = initialize_grid(Unit.where("parent_id = ? or id = ? or parent_id in (?)", current_user.unit_id, current_user.unit_id, lv3units).order(:unit_level, :no), per_page: 1000,:name => 'g1')
      @relevant_departments_grid = initialize_grid(Unit.where(is_facility_management_unit: true).order(:no), per_page: 1000,:name => 'g2')
    end
  end

  def edit
  end
  def to_report
    @units = nil
    @relevant_units = nil
    @inventory = RentInventory.find(params[:id].to_i)

    if !@inventory.blank?
      if (current_user.unit.unit_level == 1) || (current_user.unit.is_facility_management_unit)
        unit_ids = @inventory.rent_inventory_units.select(:unit_id)
      elsif current_user.unit.unit_level == 2
        unit_ids = @inventory.rent_inventory_details.where(manage_unit_id: current_user.unit_id).select(:use_unit_id).distinct
      elsif current_user.unit.unit_level == 3 && !current_user.unit.is_facility_management_unit
        unit_ids = @inventory.rent_inventory_details.joins(:unit).where("units.id = ? or units.parent_id = ?", current_user.unit_id, current_user.unit_id).select("units.id").distinct
      elsif current_user.unit.unit_level == 4
        unit_ids = current_user.unit_id
      end

      @units = Unit.where(id: unit_ids).order(:unit_level, :no)

      if @inventory.relevant_unit_ids.blank? 
        @relevant_units = Unit.where(is_facility_management_unit: true).order(:no)
      else
        @relevant_units = Unit.where(id: @inventory.relevant_unit_ids.split(",").map(&:to_i))
      end
    end
  end

  def report
    @return_datas = Hash.new
    @results = Hash.new

    @inventory_id = params[:id]
    # binding.pry 
    
    @return_datas = LowValueConsumptionInventory.process_params(params)

    @results = LowValueConsumptionInventory.get_results(RentInventoryDetail, current_user, params, @return_datas)
  end

  
  def export
    return_datas = Hash.new
    results = Hash.new
   
    return_datas = LowValueConsumptionInventory.process_params(params)

    results = LowValueConsumptionInventory.get_results(RentInventoryDetail, current_user, params, return_datas)

    send_data(report_xls_content_for(return_datas, results), :type => "text/excel;charset=utf-8; header=present", :filename => "报表_#{Time.now.strftime("%Y%m%d")}.xls")  
  end

  def report_xls_content_for(return_datas, results)  
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "报表"  
  
    filter = Spreadsheet::Format.new :size => 10
    title = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center, :weight => :bold
    body = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center

    sheet1.column(0).width = 60
    1.upto(5) do |i|
      sheet1.column(i).width = 20
    end

    sheet1[0,0] = "截止时间: #{return_datas["edate"]}"
    sheet1.row(0).default_format = filter 
    # sheet1[1,0] = "盘点单位: #{return_datas["unit_names"]}"
    # sheet1.row(1).default_format = filter 
    # sheet1[2,0] = "资产归口单位: #{return_datas["relevant_unit_names"]}"
    # sheet1.row(2).default_format = filter 
    
    sheet1.row(2).concat %w{单位 总数 匹配数 不匹配数 未扫描数 待扫描数}  
    0.upto(5) do |i|
      sheet1.row(2).set_format(i, title)
    end
    count_row = 3
    results.each do |k,v|   
      sheet1[count_row,0]=Unit.find(k).try(:name)
      sheet1[count_row,1]=v[0]
      sheet1[count_row,2]=v[1]
      sheet1[count_row,3]=v[2]
      sheet1[count_row,4]=v[3]
      sheet1[count_row,5]=v[4]
      0.upto(5) do |i|
        sheet1.row(count_row).set_format(i, body)
      end

      count_row += 1
    end 

    sheet1[count_row,0]="总计"
    sheet1[count_row,1]=return_datas["total_amount"]
    sheet1[count_row,2]=return_datas["match_amount"]
    sheet1[count_row,3]=return_datas["unmatch_amount"]
    sheet1[count_row,4]=return_datas["no_scan_amount"]
    sheet1[count_row,5]=return_datas["waiting_amount"]

    0.upto(5) do |i|
      sheet1.row(count_row).set_format(i, body)
    end

    book.write xls_report  
    xls_report.string  
  end

  def sample_report
    @end_date = nil
    sum_amount = Hash.new
    status_amount = Hash.new
    @results = Hash.new
    @totals = Hash.new
    

    @inventory = RentInventory.find(params[:id].to_i)

    unless request.get?
      if !params[:end_date].blank? && !params[:end_date]["end_date"].blank?
        @end_date = LowValueConsumptionInventory.to_date(params[:end_date]["end_date"])
      end

      if (current_user.unit.unit_level == 1) || (current_user.unit.is_facility_management_unit)
        details = RentInventoryDetail.where("rent_inventory_id = ?", params[:id].to_i)
      elsif current_user.unit.unit_level == 2
        details = RentInventoryDetail.where("rent_inventory_id = ? and manage_unit_id = ?", params[:id].to_i, current_user.unit_id)
      elsif (current_user.unit.unit_level == 3) && !(current_user.unit.is_facility_management_unit)
        child_ids = Unit.where(parent_id: current_user.unit_id).select(:id)
        details = RentInventoryDetail.where("rent_inventory_id = ? and (use_unit_id = ? or use_unit_id in (?))", params[:id].to_i, current_user.unit_id, current_user.unit_id)
      elsif current_user.unit.unit_level == 4
        details = RentInventoryDetail.where("rent_inventory_id = ? and use_unit_id = ?", params[:id].to_i, current_user.unit_id)
      end
      
      sum_amount = details.group(:use_unit_id).order(:use_unit_id).count
      status_amount = details.where("end_date <= ?", @end_date.blank? ? nil : (@end_date+1)).group(:use_unit_id).group(:inventory_status).order(:use_unit_id, :inventory_status).count


      sum_amount.each do |k,v|
        match_am = status_amount[[k, "match"]].blank? ? 0 : status_amount[[k, "match"]]
        unmatch_am = status_amount[[k, "unmatch"]].blank? ? 0 : status_amount[[k, "unmatch"]]
        no_scan_am = status_amount[[k, "no_scan"]].blank? ? 0 : status_amount[[k, "no_scan"]]
        waiting_am = v-match_am-unmatch_am-no_scan_am
        @results[k]=[v, match_am, unmatch_am, no_scan_am, waiting_am]
      end
      total_amount = details.count
      @totals["total_amount"] = total_amount
      match_amount = details.where("end_date <= ? and inventory_status = ?", @end_date.blank? ? nil : (@end_date+1), "match").count
      @totals["match_amount"] = match_amount
      unmatch_amount = details.where("end_date <= ? and inventory_status = ?" ,@end_date.blank? ? nil : (@end_date+1), "unmatch").count
      @totals["unmatch_amount"] = unmatch_amount
      no_scan_amount = details.where("end_date <= ? and inventory_status = ?" ,@end_date.blank? ? nil : (@end_date+1), "no_scan").count
      @totals["no_scan_amount"] = no_scan_amount
      waiting_amount = total_amount - match_amount - unmatch_amount - no_scan_amount
      @totals["waiting_amount"] = waiting_amount


      if !params[:is_query].blank? and params[:is_query].eql?"true"
        if @results.blank?
          flash[:alert] = "无数据"
        end
        render '/low_value_consumption_inventories/sample_report'
      elsif !params[:is_query].blank? and params[:is_query].eql?"false"
        if @results.blank?
          flash[:alert] = "无数据"
          redirect_to :action => 'sample_report'
        else
          send_data(sample_report_xls_content_for(@end_date, @results, @totals),:type => "text/excel;charset=utf-8; header=present",:filename => "报表_#{Time.now.strftime("%Y%m%d")}.xls")  
        end
      end
    end  

  end

  def sample_report_xls_content_for(end_date, results, totals)  
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "报表"  
  
    filter = Spreadsheet::Format.new :size => 10
    title = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center, :weight => :bold
    body = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center

    sheet1.column(0).width = 60
    1.upto(5) do |i|
      sheet1.column(i).width = 20
    end

    sheet1[0,0] = "截止时间: #{end_date.strftime("%Y-%m-%d")}"
    sheet1.row(0).default_format = filter 
    
    sheet1.row(2).concat %w{单位 总数 匹配数 不匹配数 未扫描数 待扫描数}  
    0.upto(5) do |i|
      sheet1.row(2).set_format(i, title)
    end
    count_row = 3
    results.each do |k,v|   
      sheet1[count_row,0]=Unit.find(k).try(:name)
      sheet1[count_row,1]=v[0]
      sheet1[count_row,2]=v[1]
      sheet1[count_row,3]=v[2]
      sheet1[count_row,4]=v[3]
      sheet1[count_row,5]=v[4]
      0.upto(5) do |i|
        sheet1.row(count_row).set_format(i, body)
      end

      count_row += 1
    end 

    sheet1[count_row,0]="总计"
    sheet1[count_row,1]=totals["total_amount"]
    sheet1[count_row,2]=totals["match_amount"]
    sheet1[count_row,3]=totals["unmatch_amount"]
    sheet1[count_row,4]=totals["no_scan_amount"]
    sheet1[count_row,5]=totals["waiting_amount"]

    0.upto(5) do |i|
      sheet1.row(count_row).set_format(i, body)
    end

    book.write xls_report  
    xls_report.string  
  end
  def create
    ActiveRecord::Base.transaction do
      if !params[:g1].nil?
        units = params[:g1][:selected]
      end
      if !params[:g2].nil?
        relevant_departments = params[:g2][:selected]
      end
      if units.blank?
        flash[:alert] = "请先选择盘点单位"
        redirect_to rent_inventories_url and return
      end
      if relevant_departments.blank?
        flash[:alert] = "请先选择资产归口单位"
        redirect_to rent_inventories_url and return
      end

      if current_user.unit.unit_level == 2
        # 自己创建的盘点单
        units.each do |x|
          if !RentInventoryUnit.joins("left join rent_inventories on rent_inventory_units.rent_inventory_id=rent_inventories.id").where("rent_inventory_units.unit_id=? and (rent_inventories.status=? or rent_inventories.status=?)", x.to_i, "waiting", "doing").blank?
            uname = Unit.find(x.to_i).name
            flash[:alert] = "#{uname}存在未完成盘点单或抽样盘点单，请完成后再新开!"
            redirect_to rent_inventories_url and return
          end
        end

        # 市公司创建的盘点单
        if !RentInventoryUnit.joins("left join rent_inventories on rent_inventory_units.rent_inventory_id=rent_inventories.id").where("rent_inventory_units.unit_id=? and (rent_inventories.status=? or rent_inventories.status=?)", current_user.unit_id, "waiting", "doing").blank?
          flash[:alert] = "#{current_user.unit.name}存在未完成盘点单或抽样盘点单，请完成后再新开!"
          redirect_to rent_inventories_url and return
        end

        rent_infos = RentInfo.where("rent_infos.relevant_unit_id in (?) and rent_infos.use_unit_id in (?) and rent_infos.status = ?", relevant_departments, units, "in_use")
      else
        units.each do |x|
          lv3_unit_ids = Unit.find(x.to_i).children.select(:id)
          lv4_unit_ids = Unit.where("parent_id in (?)", lv3_unit_ids).select(:id)
        
          if !RentInventoryUnit.joins("left join rent_inventories on rent_inventory_units.rent_inventory_id=rent_inventories.id").where("(rent_inventory_units.unit_id=? or rent_inventory_units.unit_id in (?) or rent_inventory_units.unit_id in (?)) and (rent_inventories.status=? or rent_inventories.status=?)", x.to_i, lv3_unit_ids, lv4_unit_ids, "waiting", "doing").blank?
            uname = Unit.find(x.to_i).name
            flash[:alert] = "#{uname}存在未完成盘点单或抽样盘点单，请完成后再新开!"
            redirect_to rent_inventories_url and return
          end
        end

        rent_infos = RentInfo.where("rent_infos.relevant_unit_id in (?) and (rent_infos.use_unit_id in (?) or rent_infos.manage_unit_id in (?)) and rent_infos.status = ?", relevant_departments, units, units, "in_use")
      end

      if rent_infos.blank?
        flash[:alert] = "没有符合条件的其他租赁资产"
        redirect_to rent_inventories_url and return
      end

      if !params[:rent_inventory].blank?
        if params[:rent_inventory][:start_time].blank? or params[:rent_inventory][:end_time].blank?
          flash[:alert] = "请选择盘点开始时间和结束时间"
          redirect_to rent_inventories_url and return
        end

       
        @rent_inventory.no = params[:rent_inventory][:no]
        @rent_inventory.name = params[:rent_inventory][:name]
        @rent_inventory.start_time = params[:rent_inventory][:start_time]
        @rent_inventory.end_time = params[:rent_inventory][:end_time]
        @rent_inventory.desc = params[:rent_inventory][:desc]
        @rent_inventory.status = "waiting"
        @rent_inventory.create_user_id = current_user.id
        @rent_inventory.create_unit_id = current_user.unit_id
        @rent_inventory.relevant_unit_ids = relevant_departments.compact.join(",")
        
        if current_user.unit.unit_level == 2
          @rent_inventory.is_lv2_unit = true
        end

        @rent_inventory.save

        Unit.where(id: units).each do |x|
          if @rent_inventory.is_lv2_unit
            if !RentInfo.where("rent_infos.relevant_unit_id in (?) and rent_infos.use_unit_id = ? and rent_infos.status = ?", relevant_departments, x.id, "in_use").blank?
                @rent_inventory.rent_inventory_units.create(unit_id: x.id, status: "unfinished")
            end
          else
            if !RentInfo.where("rent_infos.relevant_unit_id in (?) and (rent_infos.use_unit_id = ? or rent_infos.manage_unit_id = ?) and rent_infos.status = ?", relevant_departments, x.id, x.id, "in_use").blank?
                @rent_inventory.rent_inventory_units.create(unit_id: x.id, status: "unfinished")
            end
          end
        end
        
        rent_infos.each do |x|
          if @rent_inventory.is_lv2_unit
            inventory_unit_id = RentInventoryUnit.find_by(rent_inventory_id: @rent_inventory.id, unit_id: x.use_unit_id).blank? ? nil : RentInventoryUnit.find_by(rent_inventory_id: @rent_inventory.id, unit_id: x.use_unit_id).id
          else
            inventory_unit_id = RentInventoryUnit.find_by(rent_inventory_id: @rent_inventory.id, unit_id: x.manage_unit_id).blank? ? nil : RentInventoryUnit.find_by(rent_inventory_id: @rent_inventory.id, unit_id: x.manage_unit_id).id
          end

          @rent_inventory.rent_inventory_details.create(asset_no: x.asset_no, asset_name: x.asset_name, fixed_asset_catalog_id: x.fixed_asset_catalog_id, use_at: x.use_at, amount: x.amount, brand_model: x.brand_model, use_user: x.use_user, use_unit_id: x.use_unit_id, location: x.location, area: x.area, sum: x.sum, use_right_start: x.use_right_start, use_right_end: x.use_right_end, pay_cycle: x.pay_cycle, license: x.license, deposit: x.deposit, relevant_unit_id: x.relevant_unit_id, rent_status: x.status, print_times: x.print_times, purchase_id: x.purchase_id, manage_unit_id: x.manage_unit_id, ori_asset_no: x.ori_asset_no, desc: x.desc, change_log: x.change_log, rent_info_id: x.id, inventory_status: "waiting", rent_inventory_unit_id: inventory_unit_id, annual_rent: x.annual_rent)
        end

        
      end

      respond_to do |format|
        format.html { redirect_to rent_inventories_url }
        format.json { head :no_content }
      end
    end
  end

  def update
    @rent_inventory.update(rent_inventory_params)
    respond_with(@rent_inventory)
  end

  def destroy
    @rent_inventory.destroy
    respond_with(@rent_inventory)
  end

  def cancel
    @rent_inventory.update status: "canceled"

    redirect_to request.referer
  end

  def done
    LowValueConsumptionInventory.done(@rent_inventory, @rent_inventory.rent_inventory_details, @rent_inventory.rent_inventory_units)
  
    redirect_to request.referer
  end

  def level2_index
    @is_sample = false

    if current_user.unit.unit_level == 1
      @rent_inventories = @rent_inventories.where("(rent_inventories.is_lv2_unit=? or units.is_facility_management_unit = ?) and rent_inventories.is_sample=?", true, true, false)
    elsif current_user.unit.is_facility_management_unit
      @rent_inventories = @rent_inventories.where("units.unit_level = ? and rent_inventories.is_sample=?", 1, false)
    end
    
    @rent_inventories_grid = initialize_grid(@rent_inventories, order: 'rent_inventories.created_at',
      order_direction: 'desc')
  end

  def doing_index
    @is_sample = false

    lv3_unit_ids = current_user.unit.children.select(:id)
    
    if current_user.unit.unit_level == 2
      @rent_inventories = RentInventory.includes(:rent_inventory_units).where("rent_inventories.status in (?) and (rent_inventory_units.unit_id = ? or rent_inventory_units.unit_id in (?)) and rent_inventories.create_unit_id != ? and rent_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit_id, lv3_unit_ids, current_user.unit_id, false)
    elsif current_user.unit.unit_level == 3
      @rent_inventories = RentInventory.includes(:rent_inventory_units).where("rent_inventories.status in (?) and (rent_inventory_units.unit_id = ? or rent_inventory_units.unit_id = ?) and rent_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit.parent_id, current_user.unit.id, false)
    elsif current_user.unit.unit_level == 4
      @rent_inventories = RentInventory.includes(:rent_inventory_units).where("rent_inventories.status in (?) and (rent_inventory_units.unit_id = ? or rent_inventory_units.unit_id = ? or rent_inventory_units.unit_id = ?) and rent_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit.parent_id, current_user.unit.id, current_user.unit.parent.parent_id, false)  
    end
        
    
    @rent_inventories_grid = initialize_grid(@rent_inventories, order: 'rent_inventories.created_at',
      order_direction: 'desc')
  end

  def sub_done
    LowValueConsumptionInventory.sub_done(@rent_inventory.rent_inventory_units, @rent_inventory.rent_inventory_details, current_user)

    respond_to do |format|
      format.html { redirect_to doing_index_rent_inventories_url }
      format.json { head :no_content }
    end
  end

  def sample_inventory_index
    @is_sample = true

    @rent_inventories = RentInventory.where(create_unit_id: current_user.unit_id, is_sample: true)
    @rent_inventories_grid = initialize_grid(@rent_inventories, order: 'rent_inventories.created_at',
      order_direction: 'desc')
  end

  def to_sample_inventory
    @inventory = RentInventory.new
  end

  def sample_inventory
    catalog_id = nil
    pd_unit_id = nil
    rent_infos = nil
    inventory_unit_id = nil
    pd_unit = nil
    lv4_unit_ids = nil

    ActiveRecord::Base.transaction do
      if !params[:rent_info].blank?
        if params[:rent_info][:fixed_asset_catalog_id].blank? && params[:rent_info][:lv3_unit_id].blank?
          flash[:alert] = "请选择资产类别目录或盘点单位"
          redirect_to to_sample_inventory_rent_inventories_url and return
        else
          if !params[:rent_info][:fixed_asset_catalog_id].blank?
            catalog_id = params[:rent_info][:fixed_asset_catalog_id].to_i
          end
          if !params[:rent_info][:lv3_unit_id].blank?
            pd_unit_id = params[:rent_info][:lv3_unit_id].to_i
            pd_unit = Unit.find(pd_unit_id)
          end
        end
      end

      if params[:rent_inventory].blank? or params[:rent_inventory][:start_time].blank? or params[:rent_inventory][:end_time].blank?
        flash[:alert] = "请选择盘点开始时间和结束时间"
        redirect_to to_sample_inventory_rent_inventories_url and return
      end

      rent_infos = LowValueConsumptionInventory.get_sample_infos(RentInventory, nil, nil, catalog_id, pd_unit, current_user)
  
      if rent_infos.blank?
        flash[:alert] = "没有符合条件的其他租赁资产"
        redirect_to to_sample_inventory_rent_inventories_url and return
      end

      if pd_unit_id.blank? || (!pd_unit.blank? && pd_unit.unit_level == 2)
        rent_infos.select(:manage_unit_id).distinct.each do |x|
          lv3_unit_ids = Unit.find(x.manage_unit_id).children.select(:id)
          lv4_unit_ids = Unit.where("parent_id in (?)", lv3_unit_ids).select(:id)
          if !RentInventoryUnit.joins("left join rent_inventories on rent_inventory_units.rent_inventory_id=rent_inventories.id").where("(rent_inventory_units.unit_id=? or rent_inventory_units.unit_id in (?) or rent_inventory_units.unit_id in (?)) and (rent_inventories.status=? or rent_inventories.status=?)", x.manage_unit_id, lv3_unit_ids, lv4_unit_ids, "waiting", "doing").blank?
            uname = Unit.find(x.manage_unit_id).name
            flash[:alert] = "#{uname}存在未完成盘点单或抽样盘点单，请完成后再新开!"
            redirect_to to_sample_inventory_rent_inventories_url and return
          end
        end
      elsif !pd_unit.blank? && pd_unit.unit_level == 3
        rent_infos.select(:use_unit_id).distinct.each do |x|
          if !RentInventoryUnit.joins("left join rent_inventories on rent_inventory_units.rent_inventory_id=rent_inventories.id").where("rent_inventory_units.unit_id=? and (rent_inventories.status=? or rent_inventories.status=?)", x.use_unit_id, "waiting", "doing").blank?
            uname = Unit.find(x.use_unit_id).name
            flash[:alert] = "#{uname}存在未完成盘点单或抽样盘点单，请完成后再新开!"
            redirect_to to_sample_inventory_rent_inventories_url and return
          end
        end
        if !RentInventoryUnit.joins("left join rent_inventories on rent_inventory_units.rent_inventory_id=rent_inventories.id").where("rent_inventory_units.unit_id=? and (rent_inventories.status=? or rent_inventories.status=?)", pd_unit.parent_id, "waiting", "doing").blank?
          uname = Unit.find(pd_unit.parent_id).name
          flash[:alert] = "#{uname}存在未完成盘点单或抽样盘点单，请完成后再新开!"
          redirect_to to_sample_inventory_rent_inventories_url and return
        end
      end

      if current_user.unit.unit_level == 3 && current_user.unit.is_facility_management_unit
        relevant_unit_ids = current_user.unit.id
      else
        relevant_unit_ids = rent_infos.select(:relevant_unit_id).distinct.map{|o| o.relevant_unit_id}.compact.join(",")
      end
   
      @rent_inventory = RentInventory.create no: params[:rent_inventory][:no], name: params[:rent_inventory][:name], start_time: params[:rent_inventory][:start_time], end_time: params[:rent_inventory][:end_time], desc: params[:rent_inventory][:desc], status: "waiting", create_user_id: current_user.id, create_unit_id: current_user.unit_id, is_lv2_unit: false, is_sample: true, relevant_unit_ids: relevant_unit_ids, fixed_asset_catalog_id: catalog_id, sample_unit_id: pd_unit_id
      
      if pd_unit_id.blank?
        rent_infos.select(:manage_unit_id).distinct.each do |x|
          @rent_inventory.rent_inventory_units.create(unit_id: x.manage_unit_id, status: "unfinished")  
        end
      elsif pd_unit.unit_level == 2
        @rent_inventory.rent_inventory_units.create(unit_id: pd_unit_id, status: "unfinished")
      elsif pd_unit.unit_level == 3
        Unit.where("id = ? or id in (?)", pd_unit_id, lv4_unit_ids).each do |x|
          if !rent_infos.where(use_unit_id: x.id).blank?
            @rent_inventory.rent_inventory_units.create(unit_id: x.id, status: "unfinished")
          end
        end
      end
        
      rent_infos.each do |x|
        if pd_unit_id.blank?
          inventory_unit_id =RentInventoryUnit.find_by(rent_inventory_id: @rent_inventory.id, unit_id: x.manage_unit_id).try :id
        elsif pd_unit.unit_level == 2
          inventory_unit_id = RentInventoryUnit.find_by(rent_inventory_id: @rent_inventory.id, unit_id: pd_unit_id).try :id
        elsif pd_unit.unit_level == 3
          inventory_unit_id = RentInventoryUnit.find_by(rent_inventory_id: @rent_inventory.id, unit_id: x.use_unit_id).try :id
        end

        @rent_inventory.rent_inventory_details.create(asset_no: x.asset_no, asset_name: x.asset_name, fixed_asset_catalog_id: x.fixed_asset_catalog_id, use_at: x.use_at, amount: x.amount, brand_model: x.brand_model, use_user: x.use_user, use_unit_id: x.use_unit_id, location: x.location, area: x.area, sum: x.sum, use_right_start: x.use_right_start, use_right_end: x.use_right_end, pay_cycle: x.pay_cycle, license: x.license, deposit: x.deposit, relevant_unit_id: x.relevant_unit_id, rent_status: x.status, print_times: x.print_times, purchase_id: x.purchase_id, manage_unit_id: x.manage_unit_id, ori_asset_no: x.ori_asset_no, change_log: x.change_log, rent_info_id: x.id, inventory_status: "waiting", rent_inventory_unit_id: inventory_unit_id, annual_rent: x.annual_rent)
      end

      respond_to do |format|
        format.html { redirect_to sample_inventory_index_rent_inventories_url }
        format.json { head :no_content }
      end
    end
  end

  def sample_level2_index
    @is_sample = true

    if current_user.unit.unit_level == 1
      @rent_inventories = @rent_inventories.where("(rent_inventories.is_lv2_unit=? or create_units_rent_inventories.is_facility_management_unit = ?) and rent_inventories.is_sample=?", true, true, true)
    elsif current_user.unit.is_facility_management_unit
      @rent_inventories = @rent_inventories.where("create_units_rent_inventories.unit_level = ? and rent_inventories.is_sample=?", 1, true)
    end
    
    @rent_inventories_grid = initialize_grid(@rent_inventories, order: 'rent_inventories.created_at',
      order_direction: 'desc')
  end

  def sample_inventory_doing_index
    @is_sample = true
    
    lv3_unit_ids = current_user.unit.children.select(:id)

    if current_user.unit.unit_level == 2
      @rent_inventories = RentInventory.includes(:rent_inventory_units).where("rent_inventories.status in (?) and (rent_inventory_units.unit_id = ? or rent_inventory_units.unit_id in (?)) and rent_inventories.create_unit_id != ? and rent_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit_id, lv3_unit_ids, current_user.unit_id, true)
    elsif current_user.unit.unit_level == 3
      @rent_inventories = RentInventory.includes(:rent_inventory_units).where("rent_inventories.status in (?) and (rent_inventory_units.unit_id = ? or rent_inventory_units.unit_id = ?) and rent_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit.parent_id, current_user.unit.id, true)
    elsif current_user.unit.unit_level == 4
      @rent_inventories = RentInventory.includes(:rent_inventory_units).where("rent_inventories.status in (?) and (rent_inventory_units.unit_id = ? or rent_inventory_units.unit_id = ?) and rent_inventories.is_sample = ?", ["doing", "canceled", "done"], current_user.unit.parent_id, current_user.unit.parent.parent_id, true)  
    end
        
    @rent_inventories_grid = initialize_grid(@rent_inventories, order: 'rent_inventories.created_at',
      order_direction: 'desc')
  end

  private
    def set_rent_inventory
      @rent_inventory = RentInventory.find(params[:id])
    end

    def rent_inventory_params
      params[:rent_inventory].permit(:no, :name, :desc, :start_time, :end_time)
    end
end
