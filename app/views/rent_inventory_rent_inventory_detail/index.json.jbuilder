json.array!(@rent_inventory_details) do |rent_inventory_detail|
  json.extract! rent_inventory_detail, :id
  json.url rent_inventory_detail_url(rent_inventory_detail, format: :json)
end
