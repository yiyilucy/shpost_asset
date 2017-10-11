ready = ->
  $('#start_date_start_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#end_date_end_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#purchase_buy_at').datepicker({
    showAnim:"blind",
    changeMonth:true,
    changeYear:true
  });
  $('#low_value_consumption_info_buy_at').datepicker({
    showAnim:"blind",
    changeMonth:true,
    changeYear:true
  });
$(document).ready(ready)
$(document).on('page:load', ready)