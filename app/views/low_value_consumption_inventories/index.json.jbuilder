json.array!(@low_value_consumption_inventories) do |low_value_consumption_inventory|
  json.extract! low_value_consumption_inventory, :id
  json.url low_value_consumption_inventory_url(low_value_consumption_inventory, format: :json)
end
