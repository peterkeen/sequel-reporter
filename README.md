# Sequel::Reporter

`Sequel::Reporter` is a framework for writing web-based reports using a Sequel database connection. It provides a structure and helpers.

## Installation

Add this line to your application's Gemfile:

    gem 'sequel-reporter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel-reporter

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



## To port from ledger web or write new

[ ] report class
[ ] field templates
[ ] helpers
[x] project structure
[x] config file format
[x] generator
[ ] database

So the idea is that you run "sequel-reporter new directory-name" and get a new sequel-reporter project, which consists of:

- Gemfile
- Rakefile
- application.rb     # Subclass of Sequel::Reporter::Application
- config.ru          # for running the app
- layouts/           # where report layouts live
- lib/               # auto-loaded at app start time
- migrate/           # holds database migrations
- public/            # assets that the layouts depend on
- reports/           # where reports actually live. subdir == menu


This is kind of going down the wrong track. Instead of generating a bunch of config for Sequel::Reporter it should make a Sequel::Reporter::Application subclass and configure that, more like Rails. The database connection will have to happen in Sequel::Reporter::Application#initialize, which means the config has to happen in a set. That should be ok.