module Antwort
  class EmailTemplate
    include Antwort::Helpers

    attr_reader :name, :path, :file, :body, :data, :metadata, :title, :layout

    def initialize(template_name, opts = {})
      @name = template_name
      @root = opts[:root] || Dir.pwd
      @path = "#{@root}/emails/#{@name}"
      @file = "#{@path}/index.html.erb"

      if exists?
        read_template
        @data   = load_data
        @layout = set_layout
        @title  = @metadata[:title] || 'Untitled'
      end
    end

    def exists?
      File.file? @file
    end

    def url
      "/template/#{@name}"
    end

    private

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

    def load_data
      file = "#{@root}/data/#{@name}.yml"
      Antwort::EmailData.new(file: file).data
    end

    def set_layout
      mdl = @metadata[:layout]
      layout = case
        when mdl == false
          false
        when mdl.nil?
          :'views/layout'
        else
          mdl.to_sym
      end
      layout
    end
  end
end
