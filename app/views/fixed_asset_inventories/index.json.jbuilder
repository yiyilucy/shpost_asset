json.array!(@fixed_asset_inventories) do |fixed_asset_inventory|
  json.extract! fixed_asset_inventory, :id
  json.url fixed_asset_inventory_url(fixed_asset_inventory, format: :json)
end
