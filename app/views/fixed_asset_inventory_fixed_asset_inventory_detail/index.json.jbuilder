json.array!(@fixed_asset_inventory_details) do |fixed_asset_inventory_detail|
  json.extract! fixed_asset_inventory_detail, :id
  json.url fixed_asset_inventory_detail_url(fixed_asset_inventory_detail, format: :json)
end
