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

def fake_ranking_list
  [
    { :name => 'yebob', :score => "100"},
    { :name => 'anonymous', :score => "50"},
  ]
end

get '/ranking' do
  content_type :json
  fake_ranking_list.to_json
end
