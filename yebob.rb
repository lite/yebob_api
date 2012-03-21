require 'rubygems'
require 'sinatra'
require 'json'
require 'data_mapper'

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

get '/access_token' do
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
