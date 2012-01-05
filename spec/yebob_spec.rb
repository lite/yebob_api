require_relative 'spec_helper.rb'
require 'rest-client'

root_url = '127.0.0.1:4567' 

describe 'Yebob API' do
  include Rack::Test::Methods

  it "should return top 10 scores" do 
    game_id = "test_game_id"
	RestClient.post root_url+'/api/create', :game_id => game_id, :name => 'yebob', :score => "100"
	p response
	response = RestClient.get root_url +'/api/#{game_id}'
	response.code.should == 200
  end

  it "a 404" do
    begin
      RestClient.get root_url
      raise
    rescue RestClient::ResourceNotFound => e
      e.http_code.should == 404
      e.response.code.should == 404
      e.response.body.should == body
      e.http_body.should == body
    end
  end

end
