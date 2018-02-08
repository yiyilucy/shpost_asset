class UnitsController < ApplicationController
  load_and_authorize_resource :unit

  # GET /units
  # GET /units.json
  def index
    #@unit = Unit.all
    # binding.pry
    @current_id = nil
    @current_level = nil
    if params[:id].blank?
      if current_user.unit.blank? or [0, 1].include?current_user.unit.unit_level
        @units_grid = initialize_grid(Unit.where(unit_level:[1,2]).order(:unit_level, :no))
      else
        lv3units = Unit.where(parent_id: current_user.unit_id).select(:id)
        @units_grid = initialize_grid(Unit.where("parent_id = ? or id = ? or parent_id in (?)", current_user.unit_id, current_user.unit_id, lv3units).order(:unit_level, :no))
      end
    else
      @current_id = params[:id].to_i
      @current_level = Unit.find(@current_id).unit_level
      @units_grid = initialize_grid(Unit.where(parent_id:@current_id).order(:unit_level, :no))
    end
  end

  # GET /units/1
  # GET /units/1.json
  def show
  end

  # GET /units/new
  def new
    #@unit = Unit.new
  end

  def newsub
    # binding.pry
    @parentid = params[:id]
    @unit = Unit.new
  end

  # GET /units/1/edit
  def edit
  end

  def update_unit
    @unit = Unit.find_by(id:params[:id])
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.new
    # binding.pry
    if !params["parentid"].blank?
      parent = Unit.find_by(id:params["parentid"].to_i)
      @unit.parent_id = parent.id
      @unit.unit_level = parent.unit_level+1
      @unit.no = params[:unit][:no]
      @unit.name = params[:unit][:name]
      @unit.short_name = params[:unit][:short_name]
      @unit.unit_desc = params[:unit][:unit_desc]
      @unit.tcbd_khdh = params[:unit][:tcbd_khdh]

      if !params["checkbox"].blank? and !params["checkbox"]["is_facility_management_unit"].blank?
        is_facility_management_unit = params["checkbox"]["is_facility_management_unit"]
        @unit.is_facility_management_unit = (is_facility_management_unit.eql?"1") ? true : false
      end
      
      respond_to do |format|
        if @unit.save
          format.html { render action: 'show', notice: I18n.t('controller.create_success_notice', model: '单位')}
          format.json { head :no_content }
        else
          format.html { render action: 'new' }
          format.json { render json: @unit.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
          format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @unit.update(unit_params)
        format.html { render action: 'show', notice: I18n.t('controller.update_success_notice', model: '单位') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_unit_info
    # binding.pry
    @unit = Unit.find_by(id:params[:unitid])
    @unit.no = params[:no]
    @unit.name = params[:name]
    @unit.short_name = params[:short_name]
    @unit.unit_desc = params[:unit_desc]
    @unit.tcbd_khdh = params[:tcbd_khdh]
    is_facility_management_unit = params[:is_facility_management_unit]
    @unit.is_facility_management_unit = (is_facility_management_unit.eql?"1") ? true : false
    
    respond_to do |format|
      if @unit.save
        format.html { render action: 'show', notice: I18n.t('controller.update_success_notice', model: '单位') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    # binding.pry
    if can_delete?
      @unit.destroy
    end
    respond_to do |format|
      format.html { redirect_to units_url }
      format.json { head :no_content }
    end
  end

  def destroy_unit
    # binding.pry
    @unit = Unit.find_by(id:params[:id])
    if @unit.can_delete?
      @unit.destroy
      respond_to do |format|
        format.html { redirect_to units_url }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to units_url , notice: "无法删除"}
        format.json { head :no_content }
      end
    end
  end

  def import
    unless request.get?
      if file = upload_unit(params[:file]['file'])       
        ActiveRecord::Base.transaction do
          begin
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
            
            unit2_arr = Array.new
            unit3_arr = Array.new
            unit4_arr = Array.new
            unit23_hash = Hash.new
            unit234_hash = Hash.new
            no = 2
            a = ""

            2.upto(instance.last_row) do |line|
              rowarr = instance.row(line)
              name2 = to_string(rowarr[1]).strip
              name3 = to_string(rowarr[2]).strip
              unit2_arr << name2
              unit3_arr << name3
              unit23_hash[name3] = name2
              
              if !rowarr[3].blank?
                name4 = to_string(rowarr[3]).strip
                unit4_arr << name4             
                unit234_hash[name4] = [name2,name3]
              end
            end

            unit2_arr.uniq.each do |x|
              a = x
              if Unit.find_by(name: x).blank?
                Unit.create!(name: x, unit_desc: x, no: no.to_s.rjust(4, '0'), unit_level: 2, parent_id: Unit.find_by(unit_level: 1).blank? ? nil : Unit.find_by(unit_level: 1).id, is_facility_management_unit: false, short_name: ((I18n.t("unit_short_name.#{x}").to_s.include?"translation missing") ? "" : I18n.t("unit_short_name.#{x}").to_s))

                no = no + 1
              end
            end

            unit3_arr.uniq.each do |x|
              a = x
              if Unit.find_by(name: x).blank?
                unit = Unit.create!(name: x, unit_desc: x, no: no.to_s.rjust(4, '0'), unit_level: 3, parent_id: Unit.find_by(name: unit23_hash[x]).blank? ? nil : Unit.find_by(name: unit23_hash[x]).id)
                unit.update is_facility_management_unit: (!unit.parent.blank? and unit.parent.name.eql?I18n.t("relevant_unit.parent") and ["中国邮政集团公司上海市分公司企业发展与科技部", "中国邮政集团公司上海市分公司财务部", "中国邮政集团公司上海市分公司运营管理部", "中国邮政集团公司上海市分公司安全保卫部"].include?x) ? true : false
                no = no + 1
              end
            end

            unit4_arr.uniq.each do |x|
              a = x
              if Unit.find_by(name: x).blank?
                # binding.pry
                unit = Unit.create!(name: x, unit_desc: x, no: no.to_s.rjust(4, '0'), unit_level: 4, parent_id: unit234_hash[x].blank? ? nil : (Unit.find_by(name: unit234_hash[x].last).blank? ? nil : Unit.find_by(name: unit234_hash[x].last).id) , is_facility_management_unit: false)
                no = no + 1
              end
            end

            redirect_to :action => 'index'

            rescue Exception => e
            flash[:alert] = e.message + a
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





  # def select_level3_parents
  #     @level3_parents = Unit.where(unit_level: 3, parent_id: params[:level2_parent]).order(:no).map{|u| [u.name,u.id]}
      
  #     respond_to do |format|
  #       format.js 
  #     end
  # end


  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_unit
      #@unit = Unit.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:no, :name, :unit_desc, :short_name, :tcbd_khdh, :unit_level, :parent_id, :is_facility_management_unit)
    end

    def upload_unit(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/unit/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end
        file_path
      end
    end
end
