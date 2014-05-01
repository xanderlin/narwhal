json.array!(@users) do |user|
  json.extract! user, :id, :username, :publickey
  json.url user_url(user, format: :json)
end
