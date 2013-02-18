module Sequel::Reporter
  class Config
    attr_reader :vars, :hooks

    @@should_load_user_config = true
    @@instance = nil

    def self.should_load_user_config
      @@should_load_user_config
    end

    def self.should_load_user_config=(val)
      @@should_load_user_config = val
    end

    def initialize
      @vars = {}
      @hooks = {}

      if block_given?
        yield self
      end
    end

    def set(key, value)
      @vars[key] = value
    end

    def get(key)
      @vars[key]
    end

    def add_hook(phase, &block)
      _add_hook(phase, block)
    end

    def _add_hook(phase, hook)
      @hooks[phase] ||= []
      @hooks[phase] << hook
    end

    def run_hooks(phase, data)
      if @hooks.has_key? phase
        @hooks[phase].each do |hook|
          hook.call(data)
        end
      end
      return data
    end

    def override_with(config)
      config.vars.each do |key, value|
        set key, value
      end

      config.hooks.each do |phase, hooks|
        hooks.each do |hook|
          _add_hook phase, hook
        end
      end
    end

    def load_user_config(user_dir)
      if Sequel::Reporter::Config.should_load_user_config && File.directory?(user_dir)
        if File.directory? "#{user_dir}/reports"
          dirs = self.get(:report_directories)
          dirs.unshift "#{user_dir}/reports"
          self.set :report_directories, dirs
        end

        if File.directory? "#{user_dir}/migrate"
          self.set :user_migrate_dir, "#{user_dir}/migrate"
        end

        if File.exists? "#{user_dir}/config.rb"
          self.override_with(Sequel::Reporter::Config.from_file("#{user_dir}/config.rb"))
        end
      end
    end

    def self.from_file(filename)
      File.open(filename) do |file|
        return eval(file.read, nil, filename)
      end
    end

    def self.instance
      @@instance ||= Sequel::Reporter::Config.new
    end
  end
end
