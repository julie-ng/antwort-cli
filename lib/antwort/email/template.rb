module Antwort
  class EmailTemplate
    include Antwort::Helpers
    include Antwort::FileHelpers

    attr_reader :name, :path, :file, :body, :data, :metadata, :title, :layout

    def initialize(template_name)
      @name = template_name
      @path = "emails/#{@name}"
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

    def partials
      Dir.entries(@path).select { |f| f[0] == '_' && f[-4, 4] == '.erb' }
    end

    def last_build
      built_emails = list_folders('./build')
      built_emails.select { |f| f.split('-')[0..-2].join('-') == @name }.sort.last
    end

    def images
      dir = "./assets/images/#{@name}"
      Dir.entries(dir).select { |file| file[0] != '.' }
    end

    # rubocop:disable Style/PredicateName
    def has_images?
      !images.empty?
    end
    # rubocop:enable Style/PredicateName

    def image_path(file_name)
      path      = "assets/images/#{@name}/#{file_name}"
      full_path = File.expand_path(path, Dir.pwd)
      return path if File.exist? full_path
      nil
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
      file = "data/#{@name}.yml"
      Antwort::EmailData.new(file: file).data
    end

    def set_layout
      mdl = @metadata[:layout]
      layout = if mdl == false
                 false
               elsif mdl.nil?
                 :'emails/shared/layout'
               else
                 :"emails/#{mdl}"
               end
      layout
    end
  end
end
