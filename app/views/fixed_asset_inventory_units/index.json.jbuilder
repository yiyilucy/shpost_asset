json.array!(@fixed_asset_inventory_units) do |fixed_asset_inventory_unit|
  json.extract! fixed_asset_inventory_unit, :id
  json.url fixed_asset_inventory_unit_url(fixed_asset_inventory_unit, format: :json)
end
