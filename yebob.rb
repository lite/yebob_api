require 'rubygems'
require 'sinatra'
require 'json'
require 'data_mapper'
require 'omniauth'
#require 'openid/store/filesystem'

use Rack::Session::Cookie
#use OmniAuth::Builder do
#	provider :open_id, OpenID::Store::Filesystem.new('/tmp')
#	provider :twitter, 'consumerkey', 'consumersecret'
#end

get '/' do
	<<-HTML
	<a href='/auth/twitter'>Sign in</a>

	<form action='/auth/open_id' method='post'>
	  <input type='text' name='identifier'/>
	  <input type='submit' value='Sign in with OpenID'/>
	</form>
	HTML
end
  
post '/auth/:name/callback' do
    auth = request.env['omniauth.auth']
    # do whatever you want with the information!
end

# need install dm-sqlite-adapter
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/yebob.db")

class Score
    include DataMapper::Resource
    property :id, Serial
	property :game_id, String
    property :player, String
    property :score, Integer
    property :created_at, DateTime
end

# automatically create the post table
Score.auto_migrate! unless Score.storage_exists?

configure :development do 
  use Rack::Reloader 
end

get '/api/:gameId' do 
  request.body.rewind  # in case someone already read it
  puts request.body.read
  content_type :json
  items = Score.all :limit => 10, 
                    :game_id => params[:gameId]
  items.to_json
end

get '/show/:gameId' do 
  @items = Score.all :limit => 10, 
                      :game_id => params[:gameId]
  erb :index
end

get '/new' do 
  erb :new
end

post '/api/create' do 
  request.body.rewind  # in case someone already read it
  puts request.body.read
  item = Score.new
  item.game_id = params[:gameId]
  item.player = params[:player]
  item.score = params[:score].to_i
  item.created_at = Time.now
  item.save
  redirect "/show/#{item.game_id}"
end
