require 'rubygems'

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative './spec_helper.rb'

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
  fake_headers = {"HTTP_ACCESS_TOKEN" => 'test', "HTTP_SESSION" => 'test'}
  it "should logout pass" do
    get "/logout",  {}, fake_headers
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

  # me
  it "should me pass" do
    get "/me",  {}, fake_headers
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["id"].should_not be nil
    obj["community"].should_not be nil
    obj["name"].should_not be nil
  end

  it "should me return error" do
    get "/me"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400 
    obj["msg"].should_not be nil
  end

  # share
  it "should share pass" do
    get "/share",  {:text=>"***"}, fake_headers
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 0
  end

  it "should share return error" do
    get "/share"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400 
    obj["msg"].should_not be nil
  end

  # score submit
  it "should score submit pass" do
    get "/score/submit",  {:list_id=>"***", :score=>"***"}, fake_headers
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 0
  end

  it "should score submit return error" do
    get "/score/submit"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400 
    obj["msg"].should_not be nil
  end

  # ranking lists 
  it "should ranking lists pass" do
    get "/ranking/lists",  {}, fake_headers
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["total"].should > 0
    obj["lists"].should_not be nil
    last_list = obj["lists"][-1]
    last_list.should_not be nil
    last_list["id"].should_not be nil
    last_list["name"].should_not be nil
  end

  it "should ranking lists return error" do
    get "/ranking/lists"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400 
    obj["msg"].should_not be nil
  end

  # ranking tops
  it "should ranking tops pass" do
    get "/ranking/tops",  {:list_id=>"test", :count=>10, :start=>0, :period=>"week", :zone=>"friends"}, fake_headers
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["total"].should > 0
    obj["items"].should_not be nil
    obj["index"].should > 0
    last_item = obj["items"][-1]
    last_item.should_not be nil
    last_item["id"].should_not be nil
    last_item["user"].should_not be nil
    last_item["score"].should_not be nil
  end

  it "should ranking tops return error" do
    get "/ranking/tops"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400 
    obj["msg"].should_not be nil
  end

  # status get
  it "should status get pass" do
    get "/status/get",  {}, fake_headers
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["state"].should >= 0
    obj["expires_in"].should >= 0
  end

  it "should status get return error" do
    get "/status/get"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400 
    obj["msg"].should_not be nil
  end

  # status exists
  it "should status exists pass" do
    get "/status/exists",  {:state=>1, :delete=>1}, fake_headers
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should >= 0
  end

  it "should status exists return error" do
    get "/status/exists"
    last_response.should be_ok
    obj = get_obj(last_response)
    obj["ret"].should == 400 
    obj["msg"].should_not be nil
  end

end 
