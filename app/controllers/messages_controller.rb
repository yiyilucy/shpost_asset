class MessagesController < ApplicationController
  load_and_authorize_resource

  def index
    @messages = Message.joins(:activate_asset).where("messages.is_release = ? or (messages.is_release = ? and activate_assets.create_unit_id = ?)", true, false, current_user.unit_id).where("activate_assets.status = ?", "valid")
    @messages_grid = initialize_grid(@messages,
         :order => 'messages.created_at',
         :order_direction => 'desc')
  end

  def show
    respond_with(@message)
  end

  def new
    @message = Message.new
    respond_with(@message)
  end

  def edit
  end

  def create
    @message = Message.new(message_params)
    @message.save
    respond_with(@message)
  end

  def update
    @message.update(message_params)
    respond_with(@message)
  end

  def destroy
    @message.destroy
    respond_with(@message)
  end

  def report
    @messages = nil

    unless request.get?
      if !params[:year].blank?
        @year = params[:year]
        @messages = Message.joins(:activate_asset).where("messages.created_at >= ? and messages.created_at < ? and messages.is_release = ?", Time.local(@year), Time.local((@year.to_i+1).to_s), true).order("activate_assets.create_unit_id, messages.created_at")

        if !current_user.unit.blank? && (current_user.unit.unit_level == 2)
          @messages = @messages.where("activate_assets.create_unit_id = ?", current_user.unit_id)
        end

        @all_count = Unit.where("unit_level=? or is_facility_management_unit = ?", 2, true).count
      end

      if @messages.blank?
        flash[:notice] = "无数据！"
      end
    end
        
  end

  def report_export
    unless request.get?
      @year = params[:year]
      @messages = Message.joins(:activate_asset).where("messages.created_at >= ? and messages.created_at < ? and messages.is_release = ?", Time.local(@year), Time.local((@year.to_i+1).to_s), true).order("activate_assets.create_unit_id, messages.created_at")

      if !current_user.unit.blank? && (current_user.unit.unit_level == 2)
        @messages = @messages.where("activate_assets.create_unit_id = ?", current_user.unit_id)
      end

      @all_count = Unit.where("unit_level=? or is_facility_management_unit = ?", 2, true).count

      send_data(report_xls_content_for(@messages, @all_count,@year), :type => "text/excel;charset=utf-8; header=present", :filename => "report_#{Time.now.strftime("%Y%m%d")}.xls")  
    end
  end

  def report_xls_content_for(messages, all_count, year)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "report"  
    
    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10 
    title = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center, :weight => :bold
    body = Spreadsheet::Format.new :size => 12, :border => :thin, :align => :center
    filter = Spreadsheet::Format.new :size => 14
 
    sheet1.row(0).default_format = filter  
    sheet1[0,0] = "年:#{year}"

    sheet1.row(2).concat %w{发布单位 发布内容 推送条数 已读条数 未读单位明细 发布日期 状态}
    0.upto(6) do |i|
      sheet1.row(2).set_format(i, title)
    end
    
    sheet1.column(0).width = 25
    sheet1.column(1).width = 35
    2.upto(3) do |x|
      sheet1.column(x).width = 12
    end
    sheet1.column(4).width = 50
    sheet1.column(5).width = 15

    count_row = 3

    if !messages.blank?
      last_unit = nil
      messages.each do |m|
        read_units = Unit.joins(:users).joins(:users=>[:user_messages]).where("(units.unit_level=? or units.is_facility_management_unit = ?) and user_messages.message_id = ? and user_messages.is_read = ?", 2, true, m.id, true)

        if read_units.count == 0
          unread_unints = Unit.where("unit_level=? or is_facility_management_unit = ?", 2,true).map{|x| x.print_unit_name}.compact.join(",")
        else
          unread_unints = Unit.where("unit_level=? or is_facility_management_unit = ?", 2,true).where.not("id in (?)", read_units.map{|u| u.id}).map{|x| x.print_unit_name}.compact.join(",")
        end   

        sheet1[count_row,0]=(m.activate_asset.create_unit.name.eql?last_unit) ? "" : m.activate_asset.create_unit.name
        sheet1[count_row,1]=m.activate_asset.introduce
        sheet1[count_row,2]=all_count
        sheet1[count_row,3]=read_units.count
        sheet1[count_row,4]=unread_unints
        sheet1[count_row,5]=m.created_at.strftime('%Y-%m-%d').to_s
        sheet1[count_row,6]=m.activate_asset.status_name

        last_unit = m.activate_asset.create_unit.name
        
        0.upto(6) do |i|
          sheet1.row(count_row).set_format(i, body)
        end

        count_row += 1
      end  
    end
  
    book.write xls_report  
    xls_report.string  
  end


  private
    def set_message
      @message = Message.find(params[:id])
    end

    def message_params
      params[:message]
    end
end
