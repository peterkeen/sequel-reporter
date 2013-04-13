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

      table.render.should eq("<table ><thead><tr><th><span class=\"pull-left\">foo</span></th></tr></thead><tbody><tr><td style=\"\"><span class=\"pull-left\">2</span></td></tr></tbody></table>")
    end

    it "should decorate" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate /foo/ => RightAlignDecorator.new
      end

      table.render.should eq("<table ><thead><tr><th><span class=\"pull-right\">foo</span></th></tr></thead><tbody><tr><td style=\"\"><span class=\"pull-right\">2</span></td></tr></tbody></table>")
    end

    it "should decorate with if lambda" do
      report = Sequel::Reporter::Report.from_query(@db, "select something from things order by id")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate /something/ => RightAlignDecorator.new, :if => lambda{|c,r| c.value == 'hi'}
      end

      table.render.should eq("<table ><thead><tr><th><span class=\"pull-right\">something</span></th></tr></thead><tbody><tr><td style=\"\"><span class=\"pull-right\">hi</span></td></tr><tr><td style=\"\"><span class=\"pull-left\">ho</span></td></tr></tbody></table>")
    end

    it "should decorate all cells if given all symbol" do
      report = Sequel::Reporter::Report.from_query(@db, "select id, something from things order by id limit 1")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate :all => RightAlignDecorator.new
      end

      table.render.should eq("<table ><thead><tr><th><span class=\"pull-right\">id</span></th><th><span class=\"pull-right\">something</span></th></tr></thead><tbody><tr><td style=\"\"><span class=\"pull-right\">1</span></td><td style=\"\"><span class=\"pull-right\">hi</span></td></tr></tbody></table>")
    end

    it "should decorate with multiple" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate /foo/ => Sequel::Reporter::NumberDecorator.new(3)
        t.decorate /foo/ => Sequel::Reporter::LinkDecorator.new('/something?q=:0&now=:now&title=:title&this=:this')
      end

      now = DateTime.now.strftime('%Y-%m-%d')
      table.render.should eq("<table ><thead><tr><th><span class=\"pull-right\">foo</span></th></tr></thead><tbody><tr><td style=\"\"><span class=\"pull-right\"><a href=\"/something?q=2&now=2013-04-12&title=foo&this=2\">2.000</a></span></td></tr></tbody></table>")
    end

    it "should decorate with icon decorator" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate /foo/ => Sequel::Reporter::IconDecorator.new("glass")
      end

      now = DateTime.now.strftime('%Y-%m-%d')
      table.render.should eq("<table ><thead><tr><th><span class=\"pull-left\">foo</span></th></tr></thead><tbody><tr><td style=\"\"><span class=\"pull-left\"><i class=\"icon-glass\"></i></span></td></tr></tbody></table>")
    end

    it "should add attributes to table tag" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.attributes[:class] = "table table-bordered table-striped table-hover"
      end

      now = DateTime.now.strftime('%Y-%m-%d')
      table.render.should eq("<table class=\"table table-bordered table-striped table-hover\"><thead><tr><th><span class=\"pull-left\">foo</span></th></tr></thead><tbody><tr><td style=\"\"><span class=\"pull-left\">2</span></td></tr></tbody></table>")
    end

    it "should decorate with link shortcut" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.link /foo/ => '/something?q=:0&now=:now&title=:title&this=:this'
      end

      now = DateTime.now.strftime('%Y-%m-%d')
      table.render.should eq("<table ><thead><tr><th><span class=\"pull-left\">foo</span></th></tr></thead><tbody><tr><td style=\"\"><span class=\"pull-left\"><a href=\"/something?q=2&now=2013-04-12&title=foo&this=2\">2</a></span></td></tr></tbody></table>")
    end

    it "should decorate with highlight decorator" do
      report = Sequel::Reporter::Report.from_query(@db, "select count(1) as foo from things")
      table = Sequel::Reporter::Table.new(report) do |t|
        t.decorate :all => Sequel::Reporter::HighlightDecorator.new('#00FF00')
      end

      now = DateTime.now.strftime('%Y-%m-%d')
      table.render.should eq("<table ><thead><tr><th><span class=\"pull-left\">foo</span></th></tr></thead><tbody><tr><td style=\"background-color:#00FF00\"><span class=\"pull-left\">2</span></td></tr></tbody></table>")
    end

  end
end
