require "tweetstream"
require "redis"
require "yaml"
require "json"
require "uri"

# CONFIGURATION
EVENT_HASHTAG        = "qconsp"
EVENT_REVIEW_GRADES  = {
  :green  => %w(verde green boa otima otimo show sensacional), 
  :yellow => %w(amarelo yellow mediana maisoumenos poderiasermelhor), 
  :red    => %w(vermelha red ruim fraca pessima)
}
ACCEPT_ONLY_UNIQUE_VOTES = false
# END OF CONFIGURATION

unless ENV['TW_CONSUMER_KEY']
  # Will load credentials.yml, make sure it's there
  # This must to be used only for development environment
  @oauth = YAML.load_file(File.expand_path("config/credentials.yml"))

  ENV['TW_CONSUMER_KEY'] = @oauth["consumer_key"]
  ENV['TW_CONSUMER_SECRET'] = @oauth["consumer_secret"]
  ENV['TW_OAUTH_TOKEN'] = @oauth["access_token"]
  ENV['TW_OAUTH_TOKEN_SECRET'] = @oauth["access_token_secret"]
end

# configure tweetstream instance
TweetStream.configure do |config|
  config.consumer_key       = ENV['TW_CONSUMER_KEY']
  config.consumer_secret    = ENV['TW_CONSUMER_SECRET']
  config.oauth_token        = ENV['TW_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TW_OAUTH_TOKEN_SECRET']
  config.auth_method = :oauth
end

REDIS_URL = URI.parse(ENV["REDISCLOUD_URL"] || "redis://localhost:6379")
REDIS     = Redis.new(:host => REDIS_URL.host, :port => REDIS_URL.port, :password => REDIS_URL.password)
AGENDA    = YAML.load_file(File.expand_path("config/agenda.yml"))

ORDERED_AGENDA = AGENDA.to_a.map do |talk|
  hashtag        = talk[0]
  data           = talk[1]
  data[:hashtag] = hashtag
  timestamp      = data[:start_time].to_i
  [timestamp, data]
end.sort {|x,y| x[0] <=> y[0] }

