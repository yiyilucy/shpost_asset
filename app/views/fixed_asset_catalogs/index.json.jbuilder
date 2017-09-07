json.array!(@fixed_asset_catalogs) do |fixed_asset_catalog|
  json.extract! fixed_asset_catalog, :id
  json.url fixed_asset_catalog_url(fixed_asset_catalog, format: :json)
end
