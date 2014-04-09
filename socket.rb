require 'faye/websocket'
require_relative "./config/initializer"

module TwitterVoting
  class WebSocket
    KEEPALIVE_TIME = 15 #seconds

    def initialize(app)
      @app     = app
      @clients = []

      Thread.new do
        redis_sub = Redis.new(:host => REDIS_URL.host, :port => REDIS_URL.port, :password => REDIS_URL.password)
        redis_sub.subscribe("socket_stream") do |on|
          on.message do |channel, msg|
            @clients.each {|ws| ws.send(msg) }
          end
        end
      end

      Thread.new do
        redis_sub = Redis.new(:host => REDIS_URL.host, :port => REDIS_URL.port, :password => REDIS_URL.password)
        while true
          data = {
            :ft  => "counters",
            :twt => redis_sub.get("tweet_count").to_i,
            :rtt => redis_sub.get("retweet_count").to_i,
            :vot => redis_sub.get("votes").to_i
          }
          @clients.each {|ws| ws.send(data.to_json) }
          sleep 1 #one second
        end
      end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients << ws
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          @clients.delete(ws)
          ws = nil
        end

        ws.rack_response
      else
        @app.call(env)
      end
    end
  end
end
