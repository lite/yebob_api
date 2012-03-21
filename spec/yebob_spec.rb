require_relative 'spec_helper.rb'

describe 'Yebob API' do
  include Rack::Test::Methods

  def app 
    Sinatra::Application.new
  end

  it "should login" do
    get "/login",:community=>"qq", :code=>"authcode", :state=>"ready", :redirect_url=>"/"
    last_response.should be_ok
    #last_response.body.should have_content("session:")
    #last_response.body.should have_content("user:")
  end

  it "should login error" do

    get "/login"
    #last_response.should be_ok
    last_response.body.should include "ret:400, msg:"
  end
  
end 
