#!/usr/bin/env ruby

require "rubygems"
require_relative "../config/initializer"
require_relative "./votengine"

$stdout.sync = true

@keywords = AGENDA.keys.map { |k| "#{EVENT_HASHTAG} #{k}" } 

@votengine = TwitterVoting::Engine.new(@keywords)
@client    = TweetStream::Client.new

@client.on_error do |message|
  puts "ERROR: #{message}"
end
@client.on_enhance_your_calm do
  puts "Calm down"
end
@client.on_limit do |skip_count|
  puts "You lost #{skip_count} tweets"
end

@client.on_delete do |status_id, user_id|
  puts "Tweet deleted #{status_id}"
end

puts "Starting to track: #{@keywords}..."
@client.track(@keywords) do |status|
  puts status.text
  @votengine.compute_vote(status)
end
