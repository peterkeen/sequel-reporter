$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rspec'
require 'sequel-reporter'
require 'sequel'
require 'sqlite3'

RSpec.configure do |config|
  config.before(:each) do
    @db = Sequel.sqlite
    @db.run("create table things (id integer, something text, other date)")
    @things = @db[:things]
  end
end
