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
      links = options[:links] || {}
      partial(:table, :report => report, :links => links, :render_engine => :erb)
    end

    def query(options={}, &block)
      q = capture(&block)
      report = Sequel::Reporter::Report.from_query(@db, q)
      if options[:pivot]
        report = report.pivot(options[:pivot], options[:pivot_sort_order])
      end
      report
    end

    def linkify(links, row, value, display_value)
      links.each do |key, val|
        if key.is_a? String
          key = /^#{key}$/
        end
  
        if key.match(value[1].title.to_s)
          url = String.new(links[key])
          row.each_with_index do |v,i|
            url.gsub!(":#{i}", CGI.escape(v[0].to_s))
          end
  
          url.gsub!(':title', CGI.escape(value[1].title.to_s))
          url.gsub!(':now', CGI.escape(DateTime.now.strftime('%Y-%m-%d')))
          display_value = "<a href='#{url}'>#{escape_html(display_value)}</a>"
        else
          display_value = escape_html(display_value)
        end

      end
      display_value
    end

  end
end
