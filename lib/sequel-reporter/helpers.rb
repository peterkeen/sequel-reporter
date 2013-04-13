require 'rack/utils'
require 'cgi'

module Sequel::Reporter
  module Helpers

    include Rack::Utils

    def partial(template, locals = {})
      render_engine = locals.delete(:render_engine) || settings.render_engine
      render render_engine, template, :layout => false, :locals => locals
    end

    def table(report, options = {})
      Table.new(report) do |t|
        t.decorate :all => NumberDecorator.new
        t.attributes[:class] = 'table table-striped table-hover table-bordered table-condensed'
        yield t if block_given?
      end.render
    end

    def query(options={}, &block)
      q = capture(&block)
      report = Sequel::Reporter::Report.from_query(@db, q)
      if options[:pivot]
        report = report.pivot(options[:pivot], options[:pivot_sort_order])
      end
      report
    end

    def protected!
      unless self.send(settings.authorization_func)
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      unless ENV['USERNAME'] && ENV['PASSWORD']
        return true
      end
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['USERNAME'], ENV['PASSWORD']]
    end

  end
end
