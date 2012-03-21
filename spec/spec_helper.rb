require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)
require 'sinatra'
require 'rspec'
require 'rack/test'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

require_relative '../yebob.rb'

DataMapper.setup(:default, "sqlite3::memory:")

RSpec.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end
