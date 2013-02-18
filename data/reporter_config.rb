Sequel::Reporter::Config.new do |config|
  config.set :database_url, ENV['DATABASE_URL']
  config.set :index_report, :dashboard
end
