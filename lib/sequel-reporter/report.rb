module Sequel::Reporter

  class Cell
    attr_reader :title, :value, :style
    attr_accessor :text, :align

    def initialize(title, value)
      @title = title
      @value = value
      @style = {}
      @text = value
      @align = 'left'
    end

  end

  class Report

    attr_accessor :error, :fields, :rows

    @@params = {}

    def self.params=(params)
      @@params = params
    end

    def self.params
      @@params
    end

    def self.from_query(db, query)

      new_params = {}
      @@params.each do |key, val|
        new_params[key.to_sym] = val
      end

      ds = db.fetch(query, new_params)
      report = self.new
      begin
        row = ds.first
        if row.nil?
          raise "No data"
        end
        ds.columns.each do |col|
          report.add_field col.to_s
        end

        ds.each do |row|
          vals = []
          ds.columns.each do |col|
            vals << Cell.new(col.to_s, row[col])
          end
          report.add_row(vals)
        end
      rescue Exception => e
        report.error = e
      end

      return report
    end

    def initialize
      @fields = []
      @rows = []
    end

    def add_field(field)
      @fields << field
    end

    def add_row(row)
      if row.length != @fields.length
        raise "row length not equal to fields length"
      end
      @rows << row
    end

    def each
      @rows.each do |row|
        yield row
      end
    end

    def pivot(column, sort_order)
      new_report = self.class.new

      bucket_column_index = 0
      self.fields.each_with_index do |f, i|
        if f == column
          bucket_column_index = i
          break
        else
          new_report.add_field(f)
        end
      end

      buckets = {}
      new_rows = {}

      self.each do |row|
        key = row[0, bucket_column_index].map { |r| r.value }
        bucket_name = row[bucket_column_index].value
        bucket_value = row[bucket_column_index + 1].value

        if not buckets.has_key? bucket_name
          buckets[bucket_name] = bucket_name
        end

        new_rows[key] ||= {}
        new_rows[key][bucket_name] = bucket_value
      end

      bucket_keys = buckets.keys.sort
      if sort_order && sort_order == 'desc'
        bucket_keys = bucket_keys.reverse
      end

      bucket_keys.each do |bucket|
        new_report.add_field(buckets[bucket])
      end

      new_rows.each do |key, value|
        row = key
        bucket_keys.each do |b|
          row << value[b]
        end

        new_report.add_row(row)
      end

      return new_report
    end
  end

end
