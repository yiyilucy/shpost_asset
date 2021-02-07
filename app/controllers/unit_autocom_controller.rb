class UnitAutocomController < ApplicationController
	load_and_authorize_resource :unit

	autocomplete :unit, :name, :extra_data => [:obj]

	def p_autocomplete_relevant_department_name
		term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]
	    # binding.pry
	    
	    relevant_units = Unit.where(is_facility_management_unit: true).where("units.name like ?","%#{term}%").order(:no).all
	      
	    # binding.pry
	    render :json => relevant_units.map { |relevant_unit| {:id => relevant_unit.id, :label => relevant_unit.name, :value => relevant_unit.name, :obj => obj_id} }

    end

    def p_autocomplete_use_unit_name
		term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]
	    
	    if current_user.unit.unit_level == 2
	    	lv3children = current_user.unit.children.select(:id)
	    	use_units = Unit.where("units.name like ? and (units.id = ? or units.parent_id = ? or units.parent_id in (?))","%#{term}%", current_user.unit.id, current_user.unit.id, lv3children).order(:no).all
	    elsif current_user.unit.is_facility_management_unit
	    	use_units = Unit.where("units.name like ?","%#{term}%").order(:no).all
	    elsif (current_user.unit.unit_level == 3) && (!current_user.unit.is_facility_management_unit)
			use_units = Unit.where("units.name like ? and (units.id = ? or units.parent_id = ?)", "%#{term}%", current_user.unit.id, current_user.unit.id).order(:no).all	    		
	    end
	    		
	      
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

    def p_autocomplete_low_value_consumption_parent_catalog
    	term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]

	    low_value_consumption_catalogs = LowValueConsumptionCatalog.where("(length(low_value_consumption_catalogs.code)<=6) and (low_value_consumption_catalogs.name like ? or low_value_consumption_catalogs.code like ?)", "%#{term}%", "%#{term}%").order(:code).all

	    render :json => low_value_consumption_catalogs.map { |low_value_consumption_catalog| {:id => low_value_consumption_catalog.id, :label => low_value_consumption_catalog.code+"_"+low_value_consumption_catalog.name, :value => low_value_consumption_catalog.code+"_"+low_value_consumption_catalog.name, :obj => obj_id} }
    end

    def p_autocomplete_low_value_consumption_catalog4
    	term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]
	    pid = params[:pid]

	    if !pid.blank?
			pcode = LowValueConsumptionCatalog.find(pid.to_i).code
	    	low_value_consumption_catalogs = LowValueConsumptionCatalog.where("(length(low_value_consumption_catalogs.code)=8) and (low_value_consumption_catalogs.name like ? or low_value_consumption_catalogs.code like ?) and low_value_consumption_catalogs.code like ?", "%#{term}%", "%#{term}%", "#{pcode}%").order(:code).all
	    else
	    	low_value_consumption_catalogs = LowValueConsumptionCatalog.where("(length(low_value_consumption_catalogs.code)=8) and (low_value_consumption_catalogs.name like ? or low_value_consumption_catalogs.code like ?)", "%#{term}%", "%#{term}%").order(:code).all
	    end

	    render :json => low_value_consumption_catalogs.map { |low_value_consumption_catalog| {:id => low_value_consumption_catalog.id, :label => low_value_consumption_catalog.code+"_"+low_value_consumption_catalog.name, :value => low_value_consumption_catalog.code+"_"+low_value_consumption_catalog.name, :obj => obj_id} }
    end

    def si_autocomplete_fixed_asset_catalog
    	# binding.pry
    	term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]

	    fixed_asset_catalogs = FixedAssetCatalog.where("fixed_asset_catalogs.name like ? or fixed_asset_catalogs.code like ?", "%#{term}%", "%#{term}%").order(:code).all

	    render :json => fixed_asset_catalogs.map { |fixed_asset_catalog| {:id => fixed_asset_catalog.id, :label => fixed_asset_catalog.name, :value => fixed_asset_catalog.name, :obj => obj_id} }
    end

    def si_autocomplete_low_value_consumption_catalog
    	term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]

	    lvc_catalogs = LowValueConsumptionCatalog.where("low_value_consumption_catalogs.name like ? or low_value_consumption_catalogs.code like ?", "%#{term}%", "%#{term}%").order(:code).all

	    render :json => lvc_catalogs.map { |lvc_catalog| {:id => lvc_catalog.id, :label => lvc_catalog.name, :value => lvc_catalog.name, :obj => obj_id} }
    end

    def si_autocomplete_lv3_unit
    	# binding.pry
    	term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]

	    lve_units = Unit.where("(units.name like ? or units.no like ?) and units.unit_level in (2,3)", "%#{term}%", "%#{term}%").order(:no).all

	    render :json => lve_units.map { |unit| {:id => unit.id, :label => unit.name, :value => unit.name, :obj => obj_id} }
    end

    def lvc_report_autocomplete_manage_unit
    	# binding.pry
    	term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]

	    if current_user.unit.unit_level == 2
	    	manage_units = current_user.unit
	    else
	    	manage_units = Unit.where("(units.name like ? or units.no like ?) and units.unit_level =2", "%#{term}%", "%#{term}%").order(:no).all
	    end

	    render :json => manage_units.map { |unit| {:id => unit.id, :label => unit.name, :value => unit.name, :obj => obj_id} }
    end

    def p_autocomplete_fixed_asset_parent_catalog
    	term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]

	    fixed_asset_catalogs = FixedAssetCatalog.where("(length(fixed_asset_catalogs.code)<=6) and (fixed_asset_catalogs.name like ? or fixed_asset_catalogs.code like ?)", "%#{term}%", "%#{term}%").order(:code).all

	    render :json => fixed_asset_catalogs.map { |fixed_asset_catalog| {:id => fixed_asset_catalog.id, :label => fixed_asset_catalog.code+"_"+fixed_asset_catalog.name, :value => fixed_asset_catalog.code+"_"+fixed_asset_catalog.name, :obj => obj_id} }
    end

    def p_autocomplete_fixed_asset_catalog4
    	term = params[:term]
	    obj_id = params[:objid]
	    obj = params[:obj]
	    pid = params[:pid]

	    if !pid.blank?
			pcode = FixedAssetCatalog.find(pid.to_i).code
	    	fixed_asset_catalogs = FixedAssetCatalog.where("(length(fixed_asset_catalogs.code)=8) and (fixed_asset_catalogs.name like ? or fixed_asset_catalogs.code like ?) and fixed_asset_catalogs.code like ?", "%#{term}%", "%#{term}%", "#{pcode}%").order(:code).all
	    else
	    	fixed_asset_catalogs = FixedAssetCatalog.where("(length(fixed_asset_catalogs.code)=8) and (fixed_asset_catalogs.name like ? or fixed_asset_catalogs.code like ?)", "%#{term}%", "%#{term}%").order(:code).all
	    end

	    render :json => fixed_asset_catalogs.map { |fixed_asset_catalog| {:id => fixed_asset_catalog.id, :label => fixed_asset_catalog.code+"_"+fixed_asset_catalog.name, :value => fixed_asset_catalog.code+"_"+fixed_asset_catalog.name, :obj => obj_id} }
    end
end