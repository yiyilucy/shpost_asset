json.array!(@fixed_asset_infos) do |fixed_asset_info|
  json.extract! fixed_asset_info, :id
  json.url fixed_asset_info_url(fixed_asset_info, format: :json)
end
