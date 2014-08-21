require 'fileutils'
require 'tilt'
require 'roadie'

require 'dotenv'
Dotenv.load

module Antwort
  class Builder

    @@build_dir   = File.expand_path('./build')

    def initialize(attrs={})
      @asset_server = ENV['ASSET_SERVER'] || '/assets/'
      @app ||= Antwort::Server.new
      @request ||= Rack::MockRequest.new(@app)

      @id            = create_id
      @template_name = attrs[:template]
      @template_dir  = "#{@@build_dir}/#{@template_name}-#{@id}"
    end

    def build
      request = @request.get("/template/#{@template_name}")
      if request.status == 200
        Dir.mkdir @template_dir
        build_css
        build_html(request.body)
        inline_css
        puts "Build #{@id} successful."
      else
        puts "Build failed. Template #{@template_name} not found."
      end
    end

    private

      def build_css
        css_file = "source/assets/css/#{@template_name}/main.scss"
        if File.file? css_file
          content = Tilt::ScssTemplate.new(css_file).render
          create_file(content: content, name: 'styles', ext: 'css')
        else
          puts "Build failed. CSS for #{@template_name} not found." # continues anyway
        end
      end

      def build_html(content)
        puts "template_name: #{@template_name}"
        content = content.gsub("/assets/#{@template_name}/styles.css", 'styles.css')
        @html = create_file(content: content, name: @template_name, ext: 'html')
      end

      def inline_css
        markup  = File.read(@html.path)
        document = Roadie::Document.new(markup)
        document.asset_providers = [
          Roadie::FilesystemProvider.new(@template_dir),
        ]
        inlined = cleanup_markup(document.transform)
        create_file(content: inlined, name: 'build', ext: 'html')
      end

      def cleanup_markup(markup)
        content = use_asset_server(markup)
        content = remove_livereload(content)
        content
      end

      def create_file(attrs)
        content = attrs[:content]
        name    = attrs[:name]
        ext     = attrs[:ext]

        file = File.new("#{@template_dir}/#{name}.#{ext}", "w")
        file.puts(content)
        file.close
        file
      end

      # Creates id based on current time stamp
      # e.g. 2014-08-14 15:50:25 +0200
      # becomes 20140814155025
      def create_id
        stamp = Time.now.to_s
        stamp.split(' ')[0..1].join.gsub(/(-|:)/,'')
      end

      def use_asset_server(markup='')
        replaced = "#{@asset_server}/"
        output = markup.gsub('/assets/', replaced)
        output
      end

      def remove_livereload(markup='')
        content = markup.gsub('<script type="text/javascript">', '')
        content = content.gsub('</script>', '')
        content = content.gsub('RACK_LIVERELOAD_PORT = 35729;', '')
        content = content.gsub('<script type="text/javascript" src="http://localhost:35729/livereload.js?">', '')
        content = content.gsub('<script type="text/javascript" src="/__rack/web_socket.js">', '')
        content = content.gsub('<script type="text/javascript" src="/__rack/swfobject.js">', '')
        content = content.gsub('WEB_SOCKET_SWF_LOCATION = "/__rack/WebSocketMain.swf";', '')
        content
      end
  end
end