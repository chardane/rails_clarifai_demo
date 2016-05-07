ClarifaiRuby.configure do |config|
  config.base_url       = "https://api.clarifai.com"
  config.version_path   = "/v1"
  config.client_id      = ENV['CLARIFAI_CLIENT_ID']
  config.client_secret  = ENV['CLARIFAI_CLIENT_SECRET']
end
