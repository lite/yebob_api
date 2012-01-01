require 'sinatra'
require 'json'

configure :development do 
  use Rack::Reloader 
end

# for test
get '/testsimple' do
  'OK'
end

get '/testjson' do
  content_type :json
  { :key => 'value' }.to_json
end

# ranking
def fake_ranking
  [
    { :name => 'yebob', :score => "100"},
    { :name => 'anonymous', :score => "50"},
  ]
end

get '/ranking' do
  content_type :json
  fake_ranking.to_json
end

#games
def fake_games
  [
    { :id => '1', :name => 'angry birds'},
    { :id => '2', :name => 'fruits ninja'},
  ]
end

get '/games' do
  content_type :json
  fake_games.to_json
end
