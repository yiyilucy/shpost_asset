json.array!(@rent_infos) do |rent_info|
  json.extract! rent_info, :id
  json.url rent_info_url(rent_info, format: :json)
end
