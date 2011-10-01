require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/assetpack'
require 'coffee-script'
require 'omniauth'
require 'twitter'
require 'date'

class App < Sinatra::Base
  use OmniAuth::Builder do
    if ENV['CONSUMER_KEY'].nil? or ENV['CONSUMER_SECRET'].nil?
      warn "*" * 80
      warn "WARNING: Missing consumer key or secret. First, register an app with Twitter at"
      warn "https://dev.twitter.com/apps to obtain OAuth credentials. Then, start the server"
      warn "with the command: CONSUMER_KEY=abc CONSUMER_SECRET=123 rails server"
      warn "*" * 80
    end
    use OmniAuth::Strategies::Twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
  end

  set :root, File.dirname(__FILE__)

  register Sinatra::AssetPack

  assets do
    serve '/css', from: 'css'

    css :application, [
      '/css/normalize.css', '/css/styles.css'
    ]
  end

  enable :sessions, :static
  set :public_folder, File.dirname(__FILE__) + '/public'

  helpers do
    def is_logged_in
      !session[:access_token].nil? && !session[:access_secret].nil?
    end
  end

  helpers Sinatra::ContentFor

  before do
    Twitter.configure do |config|
      config.consumer_key = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
      config.oauth_token = session[:access_token]
      config.oauth_token_secret = session[:access_secret]
    end

    @client ||= Twitter::Client.new
  end

  get '/' do
    erb :index
  end

  get '/javascripts/application.js' do
    coffee :application
  end

  get '/auth/twitter/callback' do
    session[:access_token] = request.env['omniauth.auth']['credentials']['token']
    session[:access_secret] = request.env['omniauth.auth']['credentials']['secret']
    redirect to('/timeline')
  end

  get '/timeline' do
    if !is_logged_in
      redirect to('/auth/twitter/callback')
    else
      @user = @client.user
      @tweets = @client.home_timeline.map { |t|
        { :id => t.id, :text => t.text,
          :full_name => t.user.name,
          :screen_name => t.user.screen_name,
          :created_at => DateTime.parse(t.created_at).to_s } }
      erb :timeline
    end
  end
end
