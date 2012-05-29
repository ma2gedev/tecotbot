require 'twitter'
require 'clockwork'
include Clockwork

# twitter bot
Twitter.configure do |config|
  # should be set the following
  config.consumer_key = "xxxxxxxxxxxxxxxxxxxxxx"
  config.consumer_secret = "xxxxxxxxxxxxxxxxxxxxxx"
  config.oauth_token = "xxxxxxxxxxxxxxxxxxxxxx"
  config.oauth_token_secret = "xxxxxxxxxxxxxxxxxxxxxx"
end

class TecotBot
  def initialize
    @tag = "#tecot"
	@latest_id = nil
	retweeted_by = Twitter.retweeted_by
	@latest_id = retweeted_by[0].id unless retweeted_by.empty?
	@my_id = Twitter.user.id
  end

  def retweet
    results = Twitter.search(@tag, {:rpp => 100, :since_id => @latest_id})
	results.each do |tweet|
      next if tweet.from_user_id == @my_id
      Twitter.retweet(tweet.id)
    end
	@latest_id = results[0].id unless results.empty?
  end

  def counter_follow
    (Twitter.follower_ids.ids - Twitter.friend_ids.ids).each do |id|
      Twitter.follow id
	end
  end
end

# clockwork
bot = TecotBot.new
handler do |job|
  puts "Running #{job}"
  bot.__send__(job)
end

every(1.minutes, "retweet")
every(5.minutes, "counter_follow")


