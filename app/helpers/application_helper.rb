module ApplicationHelper
	def relevant_department_select_autocom(obj_id,obj)      
    concat text_field_tag('relevant_department_name',@relename, 'data-autocomplete' => "/shpost_asset/unit_autocom/p_autocomplete_relevant_department_name?objid=#{obj_id}&obj=#{obj}")
    hidden_field(obj_id.to_sym,"relevant_unit_id");
  end

  def use_unit_select_autocom(obj_id,obj)     
    concat text_field_tag('use_unit_name',@usename, 'data-autocomplete' => "/shpost_asset/unit_autocom/p_autocomplete_use_unit_name?objid=#{obj_id}&obj=#{obj}")
    hidden_field(obj_id.to_sym,"use_unit_id");
  end

  def send_unit_select_autocom(obj_id,obj)    
    concat text_field_tag('send_unit_name',nil, 'data-autocomplete' => "/shpost_asset/unit_autocom/p_autocomplete_send_unit_name?objid=#{obj_id}&obj=#{obj}")
    hidden_field(obj_id.to_sym,"use_unit_id");
  end

  def low_value_consumption_parent_catalog_select_autocom(obj_id,obj)
    concat text_field_tag('lvc_catalog_name',@low_value_consumption_catalog, 'data-autocomplete' => "/shpost_asset/unit_autocom/p_autocomplete_low_value_consumption_parent_catalog?objid=#{obj_id}&obj=#{obj}")
    hidden_field(obj_id.to_sym,"lvc_catalog_id");
  end

  def low_value_consumption_catalog4_select_autocom(obj_id,obj,pid)
    concat text_field_tag('low_value_consumption_catalog_name',@low_value_consumption_catalog, 'data-autocomplete' => "/shpost_asset/unit_autocom/p_autocomplete_low_value_consumption_catalog4?objid=#{obj_id}&obj=#{obj}&pid=#{pid}")
    hidden_field(obj_id.to_sym,"lvc_catalog_id");
  end

  def fixed_asset_catalog_select_autocom(obj_id,obj)
    concat text_field_tag('fixed_asset_catalog_name', nil, 'data-autocomplete' => "/shpost_asset/unit_autocom/si_autocomplete_fixed_asset_catalog?objid=#{obj_id}&obj=#{obj}")
    hidden_field(obj_id.to_sym,"fixed_asset_catalog_id");
  end

  def low_value_consumption_catalog_select_autocom(obj_id,obj)
    concat text_field_tag('lvc_catalog_name', nil, 'data-autocomplete' => "/shpost_asset/unit_autocom/si_autocomplete_low_value_consumption_catalog?objid=#{obj_id}&obj=#{obj}")
    hidden_field(obj_id.to_sym,"lvc_catalog_id");
  end

  def lv3_unit_select_autocom(obj_id,obj)
    concat text_field_tag('lv3_unit_name', nil, 'data-autocomplete' => "/shpost_asset/unit_autocom/si_autocomplete_lv3_unit?objid=#{obj_id}&obj=#{obj}")
    hidden_field(obj_id.to_sym,"lv3_unit_id");
  end

  def manage_unit_select_autocom(obj_id,obj)
    concat text_field_tag('manage_unit_name', nil, 'data-autocomplete' => "/shpost_asset/unit_autocom/lvc_report_autocomplete_manage_unit?objid=#{obj_id}&obj=#{obj}")
    hidden_field(obj_id.to_sym,"manage_unit_id");
  end
end
