require_relative 'spec_helper.rb'

describe 'Yebob API' do
  include Rack::Test::Methods

  it "should return test string" do
    get '/testsimple'
    last_response.body.should == 'OK'
  end

  it "should return json object" do
    get '/testjson'
    resp = { :key => 'value' }.to_json
    last_response.body.should == resp
  end
  
  it "should return ranking object" do
    get '/ranking', params = { :token => '123456789ABCDEF0'}
    last_response.body.should == fake_ranking.to_json
  end

  it "should return games object" do
    get '/games', params = { :token => '123456789ABCDEF0'}
    last_response.body.should == fake_games.to_json
  end

end
