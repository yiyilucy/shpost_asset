module ApplicationHelper
	def relevant_department_select_autocom(obj_id,obj)
       
       concat text_field_tag('relevant_department_name',@relename, 'data-autocomplete' => "/unit_autocom/p_autocomplete_relevant_department_name?objid=#{obj_id}&obj=#{obj}")
       hidden_field(obj_id.to_sym,"relevant_unit_id");
    end

    def use_unit_select_autocom(obj_id,obj)
       
       concat text_field_tag('use_unit_name',@usename, 'data-autocomplete' => "/unit_autocom/p_autocomplete_use_unit_name?objid=#{obj_id}&obj=#{obj}")
       hidden_field(obj_id.to_sym,"use_unit_id");
    end

    def send_unit_select_autocom(obj_id,obj)
       
       concat text_field_tag('send_unit_name',nil, 'data-autocomplete' => "/unit_autocom/p_autocomplete_send_unit_name?objid=#{obj_id}&obj=#{obj}")
       hidden_field(obj_id.to_sym,"use_unit_id");
    end

    def low_value_consumption_catalog_select_autocom(obj_id,obj)
      concat text_field_tag('low_value_consumption_catalog_name',@low_value_consumption_catalog, 'data-autocomplete' => "/unit_autocom/p_autocomplete_low_value_consumption_catalog?objid=#{obj_id}&obj=#{obj}")
       hidden_field(obj_id.to_sym,"lvc_catalog_id");
    end
end
