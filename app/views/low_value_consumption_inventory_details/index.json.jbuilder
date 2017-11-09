json.array!(@low_value_consumption_inventory_details) do |low_value_consumption_inventory_detail|
  json.extract! low_value_consumption_inventory_detail, :id
  json.url low_value_consumption_inventory_detail_url(low_value_consumption_inventory_detail, format: :json)
end
