// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require wice_grid
//= require autocomplete-rails


//= require twitter/bootstrap
//= require turbolinks
//= require_tree .


function ajaxunits() {
	$('#relevant_department_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var ruid = "#"+data.item.obj+"_relevant_unit_id";
    $(ruid).val(data.item.id);
  });

	$('#use_unit_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var useid = "#"+data.item.obj+"_use_unit_id";
    $(useid).val(data.item.id);
  });

	$('#send_unit_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var sendid = "#"+data.item.obj+"_use_unit_id";
    $(sendid).val(data.item.id);
  });

  $('#low_value_consumption_catalog_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var catalogid = "#"+data.item.obj+"_low_value_consumption_catalog_id";
    $(catalogid).val(data.item.id);
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);