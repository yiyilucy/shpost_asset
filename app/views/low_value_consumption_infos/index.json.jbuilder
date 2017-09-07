json.array!(@low_value_consumption_infos) do |low_value_consumption_info|
  json.extract! low_value_consumption_info, :id
  json.url low_value_consumption_info_url(low_value_consumption_info, format: :json)
end
