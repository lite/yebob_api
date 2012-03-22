require 'rubygems'
require 'sinatra'
require 'json' # require 'yajl'
require 'data_mapper'

#enable :sessions # disable this

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

get '/' do
  #env.inspect
  #params.inspect
  #request.inspect
  #t = %w[text/css text/html application/javascript]
  #request.accept              # ['text/html', '*/*']
  #request.accept? 'text/xml'  # true
  #request.preferred_type(t)   # 'text/html'
  #request.body                # request body sent by the client (see below)
  #request.scheme              # "http"
  #request.script_name         # "/example"
  #request.path_info           # "/foo"
  #request.port                # 80
  #request.request_method      # "GET"
  #request.query_string        # ""
  #request.content_length      # length of request.body
  #request.media_type          # media type of request.body
  #request.host                # "example.com"
  ##request.get?                # true (similar methods for other verbs)
  #request.form_data?          # false
  #request["SOME_HEADER"]      # value of SOME_HEADER header
  #request.referrer            # the referrer of the client or '/'
  request.user_agent          # user agent (used by :agent condition)
  #request.cookies             # hash of browser cookies
  #request.xhr?                # is this an ajax request?
  #request.url                 # "http://example.com/example/foo"
  #request.path                # "/example/foo"
  #request.ip                  # client IP address
  #request.secure?             # false (would be true over ssl)
  #request.forwarded?          # true (if running behind a reverse proxy)
  #request.env                 # raw env hash handed in by Rack
end

get '/access_token' do
  if params.include?("app_id")
    return {:access_token=>"test", :expire_in => "test"}.to_json
  end 
  {:ret=>400, :msg => 'test'}.to_json
end

get '/login' do
  if params.include?("code")
    return {:session=>'test', :user => 'test'}.to_json
  end 
  {:ret=>400, :msg => 'test'}.to_json
end

get '/logout' do
  if request_headers["access_token"].nil? 
    return {:ret=>400, :msg => 'test'}.to_json
  end
  session.clear
end

get '/me' do
  if request_headers["access_token"].nil? 
    return {:ret=>400, :msg => 'test'}.to_json
  end
  return {:id=>"test", :community=>"test", :name=>"test"}.to_json
end

get '/share' do
  if not params.include?("text") 
    return {:ret=>400, :msg => 'test'}.to_json
  end
  return {:ret=>0}.to_json
end

get '/score/submit' do
  if not params.include?("list_id") 
    return {:ret=>400, :msg => 'test'}.to_json
  end
  return {:ret=>0}.to_json
end

get '/ranking/lists' do
  if request_headers["access_token"].nil? 
    return {:ret=>400, :msg => 'test'}.to_json
  end
  lists = [{:id=>1, :name=>"test1"}, {:id=>2, :name=>"test2"}]
  return {:total=>1, :lists=>lists}.to_json
end

get '/ranking/tops' do
  if not params.include?("list_id") 
    return {:ret=>400, :msg => 'test'}.to_json
  end
  items = [{:id=>1, :user=>"test1", :score=>100}, {:id=>2, :user=>"test2", :score=>99}]
  return {:total=>45, :items=>items, :index=>10}.to_json
end

# get request header
helpers do
  def request_headers
    env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
  end
end

# will change
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

