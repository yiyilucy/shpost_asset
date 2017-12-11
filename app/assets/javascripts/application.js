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
    var catalogid = "#"+data.item.obj+"_lvc_catalog_id";
    $(catalogid).val(data.item.id);
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

  

}




$(document).ready(ready);
$(document).on('page:load', ready);