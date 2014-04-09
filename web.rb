require "sinatra/base"
require_relative "./config/initializer"

module TwitterVoting
  class Dashboard < Sinatra::Base

    before do
      @twtcount    = (REDIS.get "tweet_count") || "0"
      @rttcount    = (REDIS.get "retweet_count") || "0"
      @votcount    = (REDIS.get "votes") || "0"
      @agenda      = ORDERED_AGENDA
    end
    
    get '/' do
      erb :index
    end

    get '/event/:hashtag' do
      if AGENDA.keys.include?(params[:hashtag])
        @hashtag = params[:hashtag]
        @event   = AGENDA[@hashtag]
        @green   = (REDIS.get "votes:#{@hashtag}:green") || "0"
        @yellow  = (REDIS.get "votes:#{@hashtag}:yellow") || "0"
        @red     = (REDIS.get "votes:#{@hashtag}:red") || "0"
        @votes   = (REDIS.get "votes:#{@hashtag}") || "0"
        erb :event
      else
        redirect to('/')
      end
    end

  end
end
