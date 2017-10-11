json.array!(@sequences) do |sequence|
  json.extract! sequence, :id
  json.url sequence_url(sequence, format: :json)
end
