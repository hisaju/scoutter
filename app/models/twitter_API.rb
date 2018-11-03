require 'twitter'
require 'singleton'

class TwitterAPI
  include Singleton

  attr_reader :client

  @@fav_point = ActionPoint.fav.point

  @@retweet_point = ActionPoint.retweet.point

  @@quote_point = ActionPoint.quote.point

  @@reply_point = ActionPoint.reply.point

  @@xs_tweet_point = ActionPoint.xs_tweet.point
  @@s_tweet_point = ActionPoint.s_tweet.point
  @@l_tweet_point = ActionPoint.l_tweet.point
  @@xl_tweet_point = ActionPoint.xl_tweet.point

  @@xs_tweet_minimum = ActionQuality.xs_tweet.minimum
  @@s_tweet_minimum = ActionQuality.s_tweet.minimum
  @@l_tweet_minimum = ActionQuality.l_tweet.minimum
  @@xl_tweet_minimum = ActionQuality.xl_tweet.minimum
  @@xs_tweet_maximum = ActionQuality.xs_tweet.maximum
  @@s_tweet_maximum = ActionQuality.s_tweet.maximum
  @@l_tweet_maximum = ActionQuality.l_tweet.maximum
  @@xl_tweet_maximum = ActionQuality.xl_tweet.maximum

  @@fav_limit = Action.fav.limit
  @@retweet_limit = Action.retweet.limit
  @@quote_limit = Action.quote.limit
  @@reply_limit = Action.reply.limit
  @@tweet_limit = Action.tweet.limit

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
    end
  end

  class << self
    def powering(uid, user)
      # scoreとpowerを計算
      score = fav(uid, user) + retweet(uid) + quote(uid) + reply(uid) + tweet(uid)
      power = score_to_power(score, user)
      # powerをDBに追加or更新
      daily_power_record = user.power_levels.daily.first_or_initialize
      daily_power_record.update_attributes(power: power)
      # sum_powersの日次、週次、累計を保存or更新
      user.sum_powers.bulk_create_or_update
      # 戦闘力の合計値によって、ユーザーのキャラクターを変更
      chara_id = Character.decide_character_id(user.total_power)
      user.update(character_id: chara_id) if user.character_id != chara_id
    end

    def fav(uid, user)
      total_fav = TwitterAPI.get_total_favorites_count(uid)
      activity = Activity.find_by(user_id: user.id, action_id: 1)

      # 初回ログイン時にいいねのトータル回数の初期値を入れるため、yesterday_valueにtotal_favを代入している。よって初回ログイン時のいいねのポイントは無効化。
      if activity == nil
        Activity.create(user_id: user.id, action_id: 1, yesterday_value: total_fav, latest_value: total_fav)
        @fav = @@fav_point * 0
        # 初期値を入れた後は、戦闘力を測るたびにlatest_valueに最新のトータルいいね数が更新され続け、yesterday_valueとの差分で1日のいいね数を計測。latest_valueはcronにより毎日0時に更新され、yesterday_valueに格納される
      else
        yesterday_fav = Activity.find_by(user_id: user.id, action_id: 1).yesterday_value
        fav_count = (total_fav - yesterday_fav) > @@fav_limit ? @@fav_limit : (total_fav - yesterday_fav)
        @fav = @@fav_point * fav_count
        activity.latest_value = total_fav
        activity.save
      end
      @fav
    end

    def retweet(uid)
      retweet_count = TwitterAPI.get_retweets_from_today(uid)
      @retweet = @@retweet_point * retweet_count
    end

    def quote(uid, quote = [])
      TwitterAPI.get_tweets_from_today(uid).each { |tweet| quote << tweet if tweet.quote? }
      quote_count = quote.count > @@quote_limit ? @@quote_limit : quote.count
      @quote = @@quote_point * quote_count
    end

    def reply(uid)
      reply_count = TwitterAPI.get_replies_from_today(uid)
      reply_count = @@reply_limit if reply_count > @@reply_limit
      @reply = @@reply_point * reply_count
    end

    def tweet(uid, xs_tweet_count = 0, s_tweet_count = 0, l_tweet_count = 0, xl_tweet_count = 0)
      TwitterAPI.get_tweets_from_today(uid).each do |tweet|
        unless tweet.quote?
          if tweet.text.length.between?(@@xs_tweet_minimum, @@xs_tweet_maximum)
            xs_tweet_count += 1
          elsif tweet.text.length.between?(@@s_tweet_minimum, @@s_tweet_maximum)
            s_tweet_count += 1
          elsif tweet.text.length.between?(@@l_tweet_minimum, @@l_tweet_maximum)
            l_tweet_count += 1
          elsif tweet.text.length.between?(@@xl_tweet_minimum, @@xl_tweet_maximum)
            xl_tweet_count += 1
          end
        end
      end
      xs_tweet = @@xs_tweet_point * xs_tweet_count
      s_tweet = @@s_tweet_point * s_tweet_count
      l_tweet = @@l_tweet_point * l_tweet_count
      xl_tweet = @@xl_tweet_point * xl_tweet_count

      @tweet = xs_tweet + s_tweet + l_tweet + xl_tweet
    end

    def score_to_power(score, user)
      (score * user.character.growth_rate).round
    end

    def update_user_info(user, uid)
      update_name(user, uid)
      update_twitter_id(user, uid)
      update_image(user, uid)
    end

    def update_name(user, uid)
      user.update(name: TwitterAPI.instance.client.user(uid).name) if user.name != TwitterAPI.instance.client.user(uid).name
    end

    def update_twitter_id(user, uid)
      user.update(twitter_id: TwitterAPI.instance.client.user(uid).screen_name) if user.twitter_id != TwitterAPI.instance.client.user(uid).screen_name
    end

    def update_image(user, uid)
      user.update(image: TwitterAPI.instance.client.user(uid).profile_image_url_https) if user.image != TwitterAPI.instance.client.user(uid).profile_image_url_https
    end

    def get_total_favorites_count(uid)
      instance.client.user(uid).favorites_count
    end

    def get_retweets_from_today(uid)
      instance.client.retweeted_by_user(uid, options = { count: @@retweet_limit }).select { |tweet| tweet.created_at > Time.now.beginning_of_day }.count
    end

    def get_replies_from_today(uid)
      instance.client.user_timeline(uid, options = { count: 200 }).select { |tweet| tweet.created_at > Time.now.beginning_of_day }.count - TwitterAPI.instance.client.user_timeline(uid, options = { count: 200, exclude_replies: true }).select { |tweet| tweet.created_at > Time.now.beginning_of_day }.count
    end

    def get_tweets_from_today(uid)
      instance.client.user_timeline(uid, options = { count: @@tweet_limit, exclude_replies: true, include_rts: false }).select { |tweet| tweet.created_at > Time.now.beginning_of_day }
    end

  end
end
