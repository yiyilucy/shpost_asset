json.array!(@rent_inventories) do |rent_inventory|
  json.extract! rent_inventory, :id
  json.url rent_inventory_url(rent_inventory, format: :json)
end
