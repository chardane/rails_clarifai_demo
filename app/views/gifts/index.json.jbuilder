json.array!(@gifts) do |gift|
  json.extract! gift, :id, :item, :quantity, :bought
  json.url gift_url(gift, format: :json)
end
