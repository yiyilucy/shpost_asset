json.array!(@lvc_discards) do |lvc_discard|
  json.extract! lvc_discard, :id
  json.url lvc_discard_url(lvc_discard, format: :json)
end
