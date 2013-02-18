require 'thor'

module Sequel::Reporter
  class CLI < Thor

    include Thor::Actions

    desc "new NAME","Create a new Sequel::Reporter project"
    def new(name)
      empty_directory(name)
      self.destination_root = name
      copy_file("Gemfile")
      copy_file("Rakefile")
      copy_file("reporter_config.rb")
      copy_file("config.ru")
      directory("layouts")
      directory("lib")
      directory("migrate")
      directory("public")
      directory("reports")
    end

    def self.source_root
      File.expand_path("../../../data", __FILE__)
    end
  end
end
