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

  $('#lvc_catalog_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var catalogid = "#"+data.item.obj+"_lvc_catalog_id";
    $(catalogid).val(data.item.id);
    // alert(data.item.id);
    $("#low_value_consumption_catalog_name").attr("data-autocomplete", "/shpost_asset/unit_autocom/p_autocomplete_low_value_consumption_catalog4?objid=low_value_consumption_info&obj=obj&pid="+data.item.id)
  });

  $('#low_value_consumption_catalog_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var catalogid = "#"+data.item.obj+"_lvc_catalog_id";
    $(catalogid).val(data.item.id);
  });

  $('#fixed_asset_catalog_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var catalogid = "#"+data.item.obj+"_fixed_asset_catalog_id";
    $(catalogid).val(data.item.id);
  });

  $('#lv3_unit_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var unitid = "#"+data.item.obj+"_lv3_unit_id";
    $(unitid).val(data.item.id);
  });

  $('#manage_unit_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    var unitid = "#"+data.item.obj+"_manage_unit_id";
    $(unitid).val(data.item.id);
  });
}

var ready;
var lastMenuId = "";
ready = function() {
  //set menu selected
  $(".mu-a").click(function(){
    lastMenuId = $(this).parent().parent().parent().attr("id").replace(/menu-group-/,"");
  });
  if (lastMenuId != "") {
    $("#menu-group-" + lastMenuId + " .menu-title").addClass("selected");
    var parentIdsArray = lastMenuId.split("-");
    var toDisplayId = parentIdsArray[0];
    for (var i = 1; i < parentIdsArray.length - 1; i++) {
      toDisplayId += "-" + parentIdsArray[i];
      $("#menu-" + toDisplayId).addClass("in");
    };
  };

  $("a.showmask").click(function(event) {
    showMask();
  });

  $("input.showmask").click(function(event) {
    showMask();
  });

  $("button.wg-external-submit-button").click(function(event) {
    showMask();
  });

  $("button.wg-external-reset-button").click(function(event) {
    showMask();
  });

  $("a.btn#confirm").click(function(event) {
    // alert("start");
    // event.preventDefault();

    var ahref = $(this).attr('href');
    var amethod = $(this).attr('data-method');
    // alert(ahref);
    // var a = document.createElement('A');
    // a.href = ahref;  // 设置相对路径给a
    // ahref = a.href;  // 此时相对路径已经变成绝对路径
    alert("已生成");

    // $.get(ahref, function(){
    //   // alert("get");
    //   return;
    // });
    return;
  });

  $("#all_units_checked_fix").click(function() { 
    if($(this).is(':checked')){
      $("#funit input[type=checkbox]").prop("checked",true);
    }else{
      $("#funit input[type=checkbox]").prop("checked",false);
    }
  });

  $("#all_rels_checked_fix").click(function() { 
    if($(this).is(':checked')){
      $("#frel input[type=checkbox]").prop("checked",true);
    }else{
      $("#frel input[type=checkbox]").prop("checked",false);
    }
  });

  $("#all_units_checked_low").click(function() { 
    if($(this).is(':checked')){
      $("#lunit input[type=checkbox]").prop("checked",true);
    }else{
      $("#lunit input[type=checkbox]").prop("checked",false);
    }
  });

  $("#all_rels_checked_low").click(function() { 
    if($(this).is(':checked')){
      $("#lrel input[type=checkbox]").prop("checked",true);
    }else{
      $("#lrel input[type=checkbox]").prop("checked",false);
    }
  });

  $('#catalog_catalog1').click(function(){
    $.ajax({
      type : 'GET',
      url : '/shpost_asset/low_value_consumption_infos/select_catalog2/',
      data: { catalog1: $('#catalog_catalog1').val()},
      dataType : 'script'
    });
   return false;
  }); 
  $('#catalog2').click(function(){
    $.ajax({
      type : 'GET',
      url : '/shpost_asset/low_value_consumption_infos/select_catalog3/',
      data: { catalog2: $('#catalog2').val()},
      dataType : 'script'
    });
   return false;
  }); 
  $('#catalog3').click(function(){
    $.ajax({
      type : 'GET',
      url : '/shpost_asset/low_value_consumption_infos/select_catalog4/',
      data: { catalog3: $('#catalog3').val()},
      dataType : 'script'
    });
   return false;
  }); 

  $('#lvc_catalog_name').val(' ');

  if($("#is_batch").val()=="1"){
    $("#low_value_consumption_catalog_name").val(' ');
    $('#relevant_department_name').val(' ');
    $('#use_unit_name').val(' ');
    $('#low_value_consumption_info_lvc_catalog_id').val('');
    $('#low_value_consumption_info_relevant_unit_id').val('');
    $('#low_value_consumption_info_use_unit_id').val('');
  }

  $('#turn_to_page').change(function(){
    ori_url = $('#ori_url').val();
    mname = $('#mname').val();
    to_page = $('#turn_to_page').val();
    
    to_url = ori_url+"?"+mname+"[page]="+to_page;
    
    window.open(to_url, "_self");
  }); 

  $('#catalog_fix_catalog1').click(function(){
    $.ajax({
      type : 'GET',
      url : '/shpost_asset/rent_infos/select_catalog2/',
      data: { catalog1: $('#catalog_fix_catalog1').val()},
      dataType : 'script'
    });
   return false;
  }); 
  $('#fix_catalog2').click(function(){
    $.ajax({
      type : 'GET',
      url : '/shpost_asset/rent_infos/select_catalog3/',
      data: { catalog2: $('#fix_catalog2').val()},
      dataType : 'script'
    });
   return false;
  }); 
  $('#fix_catalog3').click(function(){
    $.ajax({
      type : 'GET',
      url : '/shpost_asset/rent_infos/select_catalog4/',
      data: { catalog3: $('#fix_catalog3').val()},
      dataType : 'script'
    });
   return false;
  });
}




$(document).ready(ready);
$(document).on('page:load', ready);