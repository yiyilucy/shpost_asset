json.array!(@low_value_consumption_catalogs) do |low_value_consumption_catalog|
  json.extract! low_value_consumption_catalog, :id
  json.url low_value_consumption_catalog_url(low_value_consumption_catalog, format: :json)
end
