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
      @units_grid = initialize_grid(Unit.where(unit_level:[1,2]).order(:no))
    else
      @current_id = params[:id].to_i
      @current_level = Unit.find(@current_id).unit_level
      @units_grid = initialize_grid(Unit.where(parent_id:@current_id).order(:no))
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
    # binding.pry
    parent = Unit.find_by(id:params["parentid"].to_i)
    @unit.parent_id = parent.id
    @unit.unit_level = parent.unit_level+1
    is_facility_management_unit = params["checkbox"]["is_facility_management_unit"]
    @unit.is_facility_management_unit = (is_facility_management_unit.eql?"1") ? true : false
    
    respond_to do |format|
      if @unit.save
        format.html { render action: 'show', notice: I18n.t('controller.create_success_notice', model: '单位')}
        format.json { head :no_content }
      else
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
    @unit.desc = params[:desc]
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
      params.require(:unit).permit(:no, :name, :desc, :short_name, :tcbd_khdh, :unit_level, :parent_id, :is_facility_management_unit)
    end
end
