json.array!(@activate_assets) do |activate_asset|
  json.extract! activate_asset, :id
  json.url activate_asset_url(activate_asset, format: :json)
end
