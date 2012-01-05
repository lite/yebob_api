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

get '/api/:game_id' do
  content_type :json
  items = Score.all :limit => 10, 
                    :game_id => params[:game_id]
  items.to_json
end

get '/show/:game_id' do 
  @items = Score.all :limit => 10, 
                      :game_id => params[:game_id]
  erb :index
end

get '/new' do 
  erb :new
end

post '/api/create' do 
  item = Score.new
  item.game_id = params[:game_id]
  item.player = params[:player]
  item.score = params[:score].to_i
  item.created_at = Time.now
  item.save
  redirect "/show/#{item.game_id}"
end
