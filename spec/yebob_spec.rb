require 'rubygems'
require './spec_helper.rb'

describe 'Yebob API' do
  include Rack::Test::Methods

  def app 
    Sinatra::Application.new
  end

  def get_obj(response)
    JSON.parse(response.body)
  end

  # access_token
  it "should access_token pass" do
    get "/access_token?app_id=**********&secret=**********"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["access_token"].should_not be nil
    obj["expire_in"].should_not be nil
  end
  
  it "should access_token return error" do
    get "/access_token"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400 
    obj["msg"].should_not be nil
  end
  
  # login
  it "should login pass" do
    #get "/login" :code=>"authcode", :redirect_url=>"/"
    get "/login?community=***&code=***&state=***&redirect_url=***"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["session"].should_not be nil
    obj["user"].should_not be nil
  end

  it "should login return error" do
    get "/login"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400
    obj["msg"].should_not be nil 
  end

  # logout
  fake_ss = {"access_token" => 'test', "session" => 'test'}
  it "should logout pass" do
    get "/logout",  {}, "rack.session" => fake_ss
    last_response.should be_ok
    last_response.body.should be_empty
  end

it "should logout return error" do
    get "/logout"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400 
    obj["msg"].should_not be nil
  end
  
end 
