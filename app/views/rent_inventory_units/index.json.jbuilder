json.array!(@rent_inventory_units) do |rent_inventory_unit|
  json.extract! rent_inventory_unit, :id
  json.url rent_inventory_unit_url(rent_inventory_unit, format: :json)
end
