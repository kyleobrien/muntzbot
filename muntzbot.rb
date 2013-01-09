# muntzbot.rb
# Trolling Twitter for lulz.

require 'open-uri'
require 'rubygems'
require 'twitter'

MUNTZBOT_VERSION = "1.0.3"


# Redirect the standard output.

directory_for_script = File.expand_path(File.dirname(__FILE__))
$stdout = File.new("#{directory_for_script}/muntzbot.log", "a")
$stdout.sync = true


# Load the most recent tweet ID from the last Twitter request.

last_tweet_id = 0
should_respond = true

begin
  file = File.new("#{directory_for_script}/lasttweet.txt", "r")
  while (line = file.gets)
    last_tweet_id = line
  end
  file.close
rescue => err
  puts "Couldn't open lasttweet.txt."
  should_respond = false
end


# Configure the Twitter object.

Twitter.configure do |config|
  config.consumer_key = "zbPrmq8XXqnviIEnLs1mPA"
  config.consumer_secret = "mFmNuG2wtBGlxntGo91GduXTKivvmtnbRU9BU7Z0"
  config.oauth_token = "484501315-gk2idhNj4lh55JXcGkCRhxokbZqfvmhelduPOFLA"
  config.oauth_token_secret = "9WjXlMfRfoufERAiAvDH1qA8vhcGFIQ0gCTMgHCHttk"
end

Twitter.connection_options[:headers][:user_agent] = "muntzbot/#{MUNTZBOT_VERSION}"


# Search for the phrase "Nelson Muntz"

candidate_last_tweet_id = nil
responses = Array.new

muntzisms = Array.new(0)
40.times {muntzisms << "Ha ha!"}
9.times {muntzisms << "Haw haw!"}
muntzisms << "Smell ya later!"

Twitter.search("\"nelson muntz\"", :rpp => 25, :result_type => "recent", :since_id => last_tweet_id.to_i).results.map do |status|
  
  # Keep track of the largest tweet ID.
  
  if (candidate_last_tweet_id.nil?)
    candidate_last_tweet_id = status.id
  else
    if (status.id > candidate_last_tweet_id)
      candidate_last_tweet_id = status.id
    end
  end
  
  if (status.text.downcase.include?("nelson muntz"))
      responses << { :reply_msg => "@#{status.from_user} #{muntzisms.choice}", :reply_id => status.id }
  end
  
end


# Save the most recent tweet ID to file.

unless (candidate_last_tweet_id.nil?)
  begin
    file = File.new("#{directory_for_script}/lasttweet.txt", "w")
    file.write(candidate_last_tweet_id.to_s)
    file.close
  rescue => err
    puts "Couldn't write to lasttweet.txt."
    should_respond = false
  end
else
  puts "Nothing to respond to."
end


# Send a response.

if (should_respond)
  responses.each { |response|
    # Don't hammer the service.
    puts "#{Time.now.strftime("%Y:%m:%d %I:%M:%S")} - (#{response[:reply_id]})  #{response[:reply_msg]}"
    Twitter.update("#{response[:reply_msg]}", { :in_reply_to_status_id => response[:reply_id] })
    wait_time = (90..120).to_a.choice
    sleep(wait_time)
  }
end


# Restore standard output.

$stdout = STDOUT

