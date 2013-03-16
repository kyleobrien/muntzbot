# muntzbot.rb
# Trolling Twitter for lulz, Nelson Muntz style.

require 'open-uri'
require 'rubygems'
require 'twitter'

MUNTZBOT_VERSION = "1.0.5"
MUNTZBOT_CONSUMER_KEY = "zbPrmq8XXqnviIEnLs1mPA"
MUNTZBOT_CONSUMER_SECRET = "mFmNuG2wtBGlxntGo91GduXTKivvmtnbRU9BU7Z0"
MUNTZBOT_OAUTH_TOKEN = "484501315-gk2idhNj4lh55JXcGkCRhxokbZqfvmhelduPOFLA"
MUNTZBOT_OAUTH_SECRET = "9WjXlMfRfoufERAiAvDH1qA8vhcGFIQ0gCTMgHCHttk"

def muntzlog(text)
  puts "#{Time.now.strftime("%Y:%m:%d %I:%M:%S")} - #{text}"
end


# Redirect the standard output.

directory_for_script = File.expand_path(File.dirname(__FILE__))
$stdout = File.new("#{directory_for_script}/muntzbot.log", "a")
$stdout.sync = true


# Load the most recent tweet ID from the last Twitter API request.

last_tweet_id = 0
should_respond = true

begin
  file = File.new("#{directory_for_script}/lasttweet.txt", "r")
  while (line = file.gets)
    last_tweet_id = line
  end
  file.close
rescue => err
  muntzlog("Couldn't open lasttweet.txt. Won't @reply this round.")
  should_respond = false
end


# Configure the Twitter object.

Twitter.configure do |config|
  config.consumer_key = MUNTZBOT_CONSUMER_KEY
  config.consumer_secret = MUNTZBOT_CONSUMER_SECRET
  config.oauth_token = MUNTZBOT_OAUTH_TOKEN
  config.oauth_token_secret = MUNTZBOT_OAUTH_SECRET
end

Twitter.connection_options[:headers][:user_agent] = "muntzbot/#{MUNTZBOT_VERSION}"


# Search for the phrase "Nelson Muntz" and generate responses.

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
    if (status.text.match("[Hh][Aa][Ww][- ]?[Hh][Aa][Ww]"))
    	responses << { :reply_msg => "@#{status.from_user} Haw haw!", :reply_id => status.id }
	elsif (status.text.match("[Hh][Aa][- ]?[Hh][Aa]"))
		responses << { :reply_msg => "@#{status.from_user} Ha ha!", :reply_id => status.id }
	elsif (status.text.match("[Jj][Aa][- ]?[Jj][Aa]"))
		responses << { :reply_msg => "@#{status.from_user} ¡Ja ja!", :reply_id => status.id }
    else
    	responses << { :reply_msg => "@#{status.from_user} #{muntzisms.choice}", :reply_id => status.id }
    end
  end
end


# Save the most recent tweet ID to file.

unless (candidate_last_tweet_id.nil?)
  begin
    file = File.new("#{directory_for_script}/lasttweet.txt", "w")
    file.write(candidate_last_tweet_id.to_s)
    file.close
  rescue => err
    muntzlog("Couldn't write to lasttweet.txt. Skipping @replies.")
    should_respond = false
  end
else
  muntzlog("Nothing to respond to.")
end


# Send a response.

if (should_respond)
  responses.each { |response|
    muntzlog("(#{response[:reply_id]})  #{response[:reply_msg]}")
    update_args = { :in_reply_to_status_id => response[:reply_id] }
    Twitter.update("#{response[:reply_msg]}", update_args)

    # Don't hammer the service. Lazily mimick a human.

    wait_time = (90..120).to_a.choice
    sleep(wait_time)
  }
end


# Restore standard output.

$stdout = STDOUT

