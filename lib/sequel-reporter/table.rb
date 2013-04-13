module Sequel::Reporter
  class Table

    attr_reader :attributes

    def initialize(report)
      @report = report
      @decorators = []
      @attributes = {}
      yield self if block_given?
    end

    def decorate decorator
      @decorators << decorator
    end

    def link href
      if_clause = href.delete(:if)
      href[href.keys.first] = LinkDecorator.new(href.values.first)
      href[:if] = if_clause
      @decorators << href
    end

    def render
      header = "<thead><tr>" + @report.fields.map { |f| "<th>#{f}</th>" }.join("") + "</tr></thead>"
      body_rows = []

      @report.each do |row|
        body_rows << row.map do |cell|
          @decorators.each do |decorator|
            dec = decorator.dup
            if_clause = dec.delete(:if)
            matcher = dec.keys.first

            next unless cell.title =~ matcher
            if if_clause
              next unless if_clause.call(cell, row)
            end
            cell = dec[matcher].decorate(cell, row)
          end

          style = cell.style.map { |key, val| "#{key}:#{val}"}.join(";")
          %Q{<td align="#{cell.align}" style="#{style}">#{cell.text}</td>}
        end.join("")
      end

      body = "<tbody>" + body_rows.map { |r| "<tr>#{r}</tr>" }.join("") + "</tbody>"

      attrs = attributes.map { |key,val| "#{key}=\"#{val}\"" }.join(" ")
      "<table #{attrs}>#{header}#{body}</table>"
    end
  end

end
