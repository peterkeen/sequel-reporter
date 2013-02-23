require 'sinatra/base'
require 'sinatra/contrib'
require 'sequel'

module Sequel::Reporter
  class Application < Sinatra::Base

    helpers Sequel::Reporter::Helpers

    set :render_engine, :erb
    set :database_url, ENV['DATABASE_URL']
    set :authorization_func, :authorized

    attr_reader :db

    before do
      Sequel::Reporter::Report.params = params

      @reports = []
      Dir.glob(File.join(settings.root, "views", "reports", "*")).each do |report|
        name = File.basename(report, File.extname(report))
        @reports << [name, name.capitalize]
      end
      @reports = @reports.sort {|a,b| a[0] <=> b[0]}
    end

    get '/' do
      index_report = settings.index_report
      redirect "/reports/#{index_report.to_s}"
    end

    get '/*' do
      protected!
      begin
        render settings.render_engine, params[:splat][0].to_sym
      rescue Exception => e
        @error = e
        render :erb, :error
      end
    end

    def initialize(app=nil)
      @db = Sequel.connect(self.class.settings.database_url)

      path = File.join(settings.root, "lib", "**", "*.rb")
      Dir.glob(path).each do |file|
        next if file.match(/ruby\/1.9.1/) # in case ruby somehow got in the lib directory (don't ask)
        require file
      end
      super(app)
    end
  end
end
