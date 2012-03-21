require_relative 'spec_helper.rb'

root_url = '127.0.0.1:4567' 

describe 'Yebob API' do
  include Rack::Test::Methods

  def app 
    Sinatra::Application.new
  end

  it "should login" do
    get "/login",:community=>"qq", :code=>"authcode", :state=>"ready", :redirect_url=>"/"
    last_response.should be_ok
    last_response.body.should have_content("session:")
    last_response.body.should have_content("user:")
  end

  it "should login error" do

    get "/login"
    last_response.code.should be_ok
    last_response.body.should have_cotent("ret:400, msg:")
  end
  
end 
