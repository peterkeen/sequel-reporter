# Sequel::Reporter

`Sequel::Reporter` is a small opinionated framework for writing web-based reports using the [Sequel](http://sequel.rubyforge.org) database toolkit. It provides a simple structure and helpers for easily writing reports. There's a [tiny demo](http://sequel-reporter-demo.herokuapp.com) if you want to see an example.

## Installation

    $ gem install sequel-reporter

## Usage

Generate a new reporting project using the sequel-reporter binary:

    $ sequel-reporter new foo
    $ cd foo
    $ bundle install
    $ bundle exec rackup
    
Then navigate your browser to http://localhost:9292

## Writing Reports

Reports are `erb` files located in `views/reports`. Here's a very simple example report:

    <% @query = query do %>
      select "pete" as name, 28 as age
    <% end %>
    <%= table @query %>
    
### Helpers

The `query` helper takes a block of SQL and returns a `Sequel::Reporter::Report` instance. It can take a few options:

* `:pivot` is the name of a column to pivot the report on. 
* `:pivot_sort_order` says how to order the resulting pivoted columns. Can be `asc` or `desc`. Defaults to `asc`.

Sequel Reporter uses [Twitter Bootstrap](http://twitter.github.com/bootstrap) for formatting, so you can use whatever you want to format your reports from there. 

The `table` helper takes a query produced by the `query` helper and some options and builds an HTML table. Also, it can take a `:links` option which will linkify values in the table. Here's an example:

    :links => {"Account" => "/reports/register?account=:1"}
    
This says that every value in the `Account` column will be surrounded with an `<a>` tag pointing at `/reports/register?account=:1`, where `:1` will be replaced by the value in column 1 of that particular row. You can also use `:title` in a link template. It will get replaced with the title of the column that is currently getting linked. In this case, `:title` would get replaced with `Account`.

### Reports as Classes

Sometimes writing a report in a `erb` file isn't the most convenient thing. If you want, you can write the query portion of a report as a class and put it in the `lib` directory. All `.rb` files in `lib` and subdirectories will be loaded at application start up. The idiom to use is to construct a class with a class-level `run` method which takes a `db`, which is then passed to `from_query`. Here's an example:

    class SomeComplicatedReport < Sequel::Reporter::Report
      def self.run(db)
        from_query(db, """
          select "something complicated" as foo
        """)
      end
    end

Then in your `erb` report you'd use it like this:

    <%= table SomeComplicatedReport.run(@db) %>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
