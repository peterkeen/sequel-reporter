require 'sinatra/base'
require 'sinatra/contrib'
require 'sequel'

module Sequel::Reporter
  class Application < Sinatra::Base

    helpers Sinatra::Capture

    set :render_engine, :erb
    set :database_url, ENV['DATABASE_URL']

    attr_reader :db

    before do
      Report.params = params

      @reports = []
      Dir.glob(File.join(settings.root, "views", "reports")).each do |report|
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
      begin
        render settings.render_engine, params[:splat].to_sym
      rescue Exception => e
        @error = e
        render :erb, :error
      end
    end

    def initialize(app=nil)
      super(app)
      @db = Sequel.connect(self.class.settings.database_url)
    end
  end
end
