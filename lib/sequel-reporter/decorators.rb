require 'rack/utils'
require 'cgi'

module Sequel::Reporter

  class NumberDecorator
    def initialize(precision=2)
      @precision = precision
    end

    def decorate(cell, row)
      cell.align = 'right'
      cell.text = sprintf("%0.#{@precision}f", cell.value)
      cell
    end
  end

  class LinkDecorator
    def initialize(href_pattern)
      @href_pattern = href_pattern
    end

    def decorate(cell, row)
      url = String.new(@href_pattern)
      row.each_with_index do |c,i|
        url.gsub!(":#{i}", CGI.escape(c.value.to_s))
      end
      url.gsub!(':title', CGI.escape(cell.title.to_s))
      url.gsub!(':now', CGI.escape(DateTime.now.strftime('%Y-%m-%d')))
      url.gsub!(':this', CGI.escape(cell.value.to_s))
      prev_text = cell.text
      cell.text = "<a href=\"#{url}\">#{cell.text}</a>"
      cell
    end
  end

  class IconDecorator
    def initialize(icon)
      @icon = icon
    end

    def decorate(cell, row)
      cell.text = "<i class=\"icon-#{@icon}\"></i>"
      cell
    end
  end

end
