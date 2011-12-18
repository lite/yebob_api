require_relative '../yebob.rb'
require 'rack/test'

set :environment, :test

def app
	Sinatra::Application
end
