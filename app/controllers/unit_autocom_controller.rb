class UnitAutocomController < ApplicationController
	load_and_authorize_resource :unit

	autocomplete :unit, :name, :extra_data => [:obj]

	def p_autocomplete_relevant_department_name
		term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]
	    # binding.pry
	    
	    relevant_units = Unit.where(unit_level: [1,2]).where("units.name like ?","%#{term}%").order(:no).all
	      
	    # binding.pry
	    render :json => relevant_units.map { |relevant_unit| {:id => relevant_unit.id, :label => relevant_unit.name, :value => relevant_unit.name, :obj => obj_id} }

    end

    def p_autocomplete_use_unit_name
		term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]
	    # binding.pry
	    
	    use_units = Unit.where("units.name like ? and (units.id = ? or units.parent_id = ?)","%#{term}%", current_user.unit.id, current_user.unit.id).order(:no).all
	      
	    # binding.pry
	    render :json => use_units.map { |use_unit| {:id => use_unit.id, :label => use_unit.name, :value => use_unit.name, :obj => obj_id} }

    end

    def p_autocomplete_send_unit_name
		term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]
	    # binding.pry
	    
	    send_units = Unit.where("units.name like ? and units.unit_level = 2 and units.id != ?","%#{term}%", current_user.unit.id).order(:no).all
	      
	    # binding.pry
	    render :json => send_units.map { |send_unit| {:id => send_unit.id, :label => send_unit.name, :value => send_unit.name, :obj => obj_id} }

    end

    def p_autocomplete_low_value_consumption_catalog
    	term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]

	    low_value_consumption_catalogs = LowValueConsumptionCatalog.where("low_value_consumption_catalogs.name like ? or low_value_consumption_catalogs.code like ?", "%#{term}%", "%#{term}%").order(:code).all

	    render :json => low_value_consumption_catalogs.map { |low_value_consumption_catalog| {:id => low_value_consumption_catalog.id, :label => low_value_consumption_catalog.name, :value => low_value_consumption_catalog.name, :obj => obj_id} }
    end
end