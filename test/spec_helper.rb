$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rspec'
require 'sequel-reporter/application'
require 'sequel-reporter/report'
require 'sequel-reporter/helpers'
require 'sequel'
require 'sqlite3'

RSpec.configure do |config|
  config.before(:each) do
    @db = Sequel.sqlite
    @db.run("create table things (id integer, something text, other date)")
    @things = @db[:things]
  end
end
