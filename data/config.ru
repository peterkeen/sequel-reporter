require 'rubygems'
require 'sequel-reporter'

Sequel::Reporter::Config.instance.load_user_config(File.dirname(__FILE__))
Sequel::Reporter::Database.connect

run Sequel::Reporter::Application.new
