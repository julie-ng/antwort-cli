module Antwort
  class TemplateModel
    include Antwort::Helpers

    attr_reader :name, :path, :file, :body, :data, :metadata, :title, :layout

    def initialize(template_name, opts = {})
      @name = template_name
      @root = opts[:root] || Dir.pwd
      @path = "#{@root}/emails/#{@name}"
      @file = "#{@path}/index.html.erb"

      read_template

      @data   = get_data
      @title  = @metadata[:title] || 'Untitled'
      @layout = @metadata[:layout].nil? ? 'views/layout' : @metadata[:layout]
    end

    def read_template
      contents = File.read(@file)
      find_md = contents.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m)

      if find_md.nil?
        @body = contents
        @metadata = {}
      else
        @body = find_md.post_match
        @metadata = symbolize_keys!(YAML.load(find_md[:metadata]))
      end
    end

    def get_data
      data = {}
      data_file = "#{@root}/data/#{@name}.yml"
      if File.file? data_file
        data = YAML.load_file(data_file)
        data = symbolize_keys! data if data
      end
      data
    end
  end
end
