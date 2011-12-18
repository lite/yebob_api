require_relative 'spec_helper.rb'

describe 'Yebob API' do
	include Rack::Test::Methods	

	# it "should load the home page" do
	# 	get '/nonereal'
	# 	last_response.should be_ok
	# end

	# it "should reverse posted values as well" do
	# 	post '/', params = { :str => 'Jeff'}
	# 	last_response.body.should == 'ffeJ'
	# end

	it "should return ranking list" do
		get '/ranking', params = { :token => '123456789ABCDEF0'}
		last_response.body.should == '1st'
	end
end
