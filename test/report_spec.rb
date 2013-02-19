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
      report.each_row do |row|
        rows << row
      end

      rows[0][0][0].should eq(2)
      rows[0][0][1].should eq(Sequel::Reporter::NumberField.new('foo'))
    end

    it "should use params" do
      Sequel::Reporter::Report.params = {:blah => "hi"}
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things where something = :blah")
      rows = []
      report.each_row do |row|
        rows << row
      end

      rows[0][0][0].should eq(1)
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
        Sequel::Reporter::StringField.new('other'),
        Sequel::Reporter::NumberField.new('hi'),
        Sequel::Reporter::NumberField.new('ho'),
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
