require 'yaml'

module Antwort
  class EmailData
    include Antwort::Helpers

    attr_reader :name, :file, :path, :data

    def initialize(opts = {})
      @name = opts[:name] || ''
      @path = (opts[:path] || Dir.pwd) + '/data'
      @file = opts[:file] || "#{@path}/#{@name}.yml"
      @data = load_yaml_data
    end

    private

    def load_yaml_data
      data = {}
      if File.file? @file
        data = YAML.load_file(@file)
        data = symbolize_keys! data if data
      end
      data
    end
  end
end
