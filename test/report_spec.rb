require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Sequel::Reporter::Report do

  before :each do
    @things.insert(:id => 1, :something => "hi", :other => "2013-02-18")
    @things.insert(:id => 2, :something => "ho", :other => "2013-02-19")
  end
  
  describe "#from_query" do
    it "should run a query" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      rows = []
      report.each do |row|
        rows << row
      end

      rows[0][0].value.should eq(2)
      rows[0][0].title.should eq('foo')
    end

    it "should use params" do
      Sequel::Reporter::Report.params = {:blah => "hi"}
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things where something = :blah")
      rows = []
      report.each do |row|
        rows << row
      end

      rows[0][0].value.should eq(1)
    end
  end

  describe "#pivot" do

    before :each do
      @things.insert(:id => 1, :something => "hi", :other => "2013-02-18")
      @things.insert(:id => 2, :something => "ho", :other => "2013-02-19")
    end

    it "should create the correct fields" do
      report = Sequel::Reporter::Report.from_query(@db, "select other, something, count(1) from things group by other, something")
      report = report.pivot("something", "asc")

      report.fields.should eq([
        'other',
        'hi',
        'ho',
      ])
    end

    it "should put the values in the right place" do
      report = Sequel::Reporter::Report.from_query(@db, "select other, something, count(1) from things group by other, something")
      report = report.pivot("something", "asc")

      report.rows.should eq([
        [Date.new(2013,2,18), 2, nil],
        [Date.new(2013,2,19), nil, 2]
      ])
    end
  end

end
