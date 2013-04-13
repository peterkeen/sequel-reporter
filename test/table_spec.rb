require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

class RightAlignDecorator
  def decorate(cell, row)
    cell.align = 'right'
    cell
  end
end

describe Sequel::Reporter::Table do

  before :each do
    @things.insert(:id => 1, :something => "hi", :other => "2013-02-18")
    @things.insert(:id => 2, :something => "ho", :other => "2013-02-19")
  end

  describe "#render" do
    it "should render" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report)

      table.render.should eq("<table ><thead><tr><th>foo</th></tr></thead><tbody><tr><td align=\"left\" style=\"\">2</td></tr></tbody></table>")
    end

    it "should decorate" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate /foo/ => RightAlignDecorator.new
      end

      table.render.should eq("<table ><thead><tr><th>foo</th></tr></thead><tbody><tr><td align=\"right\" style=\"\">2</td></tr></tbody></table>")
    end

    it "should decorate with if lambda" do
      report = Sequel::Reporter::Report.from_query(@db, "select something from things order by id")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate /something/ => RightAlignDecorator.new, :if => lambda{|c,r| c.value == 'hi'}
      end

      table.render.should eq("<table ><thead><tr><th>something</th></tr></thead><tbody><tr><td align=\"right\" style=\"\">hi</td></tr><tr><td align=\"left\" style=\"\">ho</td></tr></tbody></table>")
    end

    it "should decorate with multiple" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate /foo/ => Sequel::Reporter::NumberDecorator.new(3)
        t.decorate /foo/ => Sequel::Reporter::LinkDecorator.new('/something?q=:0&now=:now&title=:title&this=:this')
      end

      now = DateTime.now.strftime('%Y-%m-%d')
      table.render.should eq("<table ><thead><tr><th>foo</th></tr></thead><tbody><tr><td align=\"right\" style=\"\"><a href=\"/something?q=2&now=#{now}&title=foo&this=2\">2.000</a></td></tr></tbody></table>")
    end

    it "should decorate with icon decorator" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate /foo/ => Sequel::Reporter::IconDecorator.new("glass")
      end

      now = DateTime.now.strftime('%Y-%m-%d')
      table.render.should eq("<table ><thead><tr><th>foo</th></tr></thead><tbody><tr><td align=\"left\" style=\"\"><i class=\"icon-glass\"></i></td></tr></tbody></table>")
    end
  end
end
