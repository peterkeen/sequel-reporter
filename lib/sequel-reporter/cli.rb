require 'thor'

module Sequel::Reporter
  class CLI < Thor

    include Thor::Actions

    desc "new NAME","Create a new Sequel::Reporter project"
    def new(name)
      @name = name

      empty_directory(name)
      self.destination_root = name
      copy_file("Gemfile")
      template("Rakefile.tt", "Rakefile")
      template("application.rb.tt", "application.rb")
      template("config.ru")
      directory("lib")
      directory("migrate")
      directory("public")
      directory("views")
    end

    def self.source_root
      File.expand_path("../../../data", __FILE__)
    end
  end
end
