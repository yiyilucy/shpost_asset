json.array!(@low_value_consumption_inventory_units) do |low_value_consumption_inventory_unit|
  json.extract! low_value_consumption_inventory_unit, :id
  json.url low_value_consumption_inventory_unit_url(low_value_consumption_inventory_unit, format: :json)
end
