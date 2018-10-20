class UsersController < ApplicationController
  require 'open3'
  require 'uri'

  #before_action :not_self_page, only: [:show]

  PATH_TO_PHANTOM_SCRIPT = Rails.root.join('app', 'assets', 'javascripts', 'screenshot.js')

  def show
    #redirect_to root_path if request.referrer == 'https://t.co/'
    @data_30days = PowerLevel.get_target_period_array(30, params[:id])
    @user = User.find(params[:id])
    @url = request.url
    @screenshot_name  = @url.gsub(/\//, '¥').concat(".jpg")
    @screenshot_path = Rails.root.join("app", "assets", "images", "#{@screenshot_name}")
    #事前に、キャプチャの保存先をmetaタグに設定する
    @asset_path = view_context.root_url.concat('assets/', "#{@screenshot_name}")
    # testurl = request.referer || ''
    # if testurl.include?('t.co')
    #   redirect_to root_path
    # end
  end

  # ボタン押下時にスクショを取るアクション
  def take_screenshot
    # public/images配下に画像を保存するようにディレクトリを変更
    Dir.chdir(Rails.root.join('app', 'assets', 'images'))
    # phantomjs用のスクリプトをsystemコマンドとして実行
    Open3.capture3("phantomjs #{PATH_TO_PHANTOM_SCRIPT} #{params[:url]} #{params[:file_name]}")
    url = set_share_url
    redirect_to url
  end

  def rank
    case @period = params[:period] || 'total'
    when 'total'
      @ranks = User.power_rank.total_period.page(params[:page]).per(25)
    when 'week'
      @ranks = User.power_rank.week_period.page(params[:page]).per(25)
    when 'day'
      @ranks = User.power_rank.day_period.page(params[:page]).per(25)
    end
  end

  private

  # twitterからのアクセスを、topページにリダイレクトさせる
  # phantomjsからのアクセスを判別し、skipさせる
  def not_self_page
    return true if params[:access] == 'phantomjs'
    redirect_to root_path if current_user&.id != params[:id].to_i
  end

  # twitterに画像およびテキスト、URL(Topページ)を投稿するための設定を行う
  def set_share_url
    tweet_url = URI.encode(
    "https://twitter.com/intent/tweet?" +
    "&url=" +
    "#{view_context.root_url}" +
    "&text=" +
    "テスト"
  )
  end
end
