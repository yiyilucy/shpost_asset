json.array!(@user_messages) do |user_message|
  json.extract! user_message, :id
  json.url user_message_url(user_message, format: :json)
end
