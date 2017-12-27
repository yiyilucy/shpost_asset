json.array!(@lvc_discard_details) do |lvc_discard_detail|
  json.extract! lvc_discard_detail, :id
  json.url lvc_discard_detail_url(lvc_discard_detail, format: :json)
end
