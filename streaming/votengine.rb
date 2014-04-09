module TwitterVoting
  class Engine
    def initialize(keywords)
      @keywords = keywords
    end

    def compute_vote(status)
      
      # counting stuff
      if status.retweet?
        REDIS.incr "retweet_count"
      end
      REDIS.incr "tweet_count"

      if is_vote_legit?(status)
        hashtags = status.hashtags.map { |h| h.text }
        talk     = extract_talk(hashtags)
        review   = extract_review(hashtags)

        vote_data = {
          :ft => "newvote",
          :sn => status.user.screen_name,
          :id => status.id,
          :tk => talk,
          :rv => review
        }.to_json

        puts vote_data

        REDIS.multi do
          REDIS.incr "votes"
          REDIS.incr "votes:#{talk}"
          REDIS.incr "votes:#{talk}:#{review}"
          REDIS.sadd "voteset:#{talk}", status.user.screen_name 
          #REDIS.publish "socket_stream:#{talk}", vote_data
          REDIS.publish "socket_stream", vote_data
        end
      end

    end

  private
    # track most vote influencers?
    # remove votes if tweet is deleted?

    def is_vote_legit?(status)
      hashtags = status.hashtags.map { |h| h.text }
      if hashtags.include?(EVENT_HASHTAG)
        talk   = extract_talk(hashtags)
        review = extract_review(hashtags)
        if talk && review
          if ACCEPT_ONLY_UNIQUE_VOTES
            return !REDIS.SISMEMBER("voteset:#{talk}", status.user.screen_name) == 0
          else
            return true
          end
        end
      end
      return false
    end

    def extract_talk(hashtags)
      hashtags.select {|h| AGENDA.keys.include?(h) }.first
    end

    def extract_review(hashtags)
      result = []
      %w(green yellow red).each do |r|
         hashtags.each do |h| 
           result << r if EVENT_REVIEW_GRADES[r.to_sym].include?(h)
         end
      end
      result.first
    end

  end
end
