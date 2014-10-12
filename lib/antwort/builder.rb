require 'fileutils'
require 'tilt'
require 'roadie'

module Antwort
  class Builder < Thor
    @@build_dir   = File.expand_path('./build')

    def initialize(attrs = {})
      @asset_server = ENV['ASSET_SERVER'] || '/assets/'
      @app ||= Antwort::Server.new
      @request ||= Rack::MockRequest.new(@app)

      @id            = create_id
      @template_name = attrs[:template]
      @template_dir  = "#{@@build_dir}/#{@template_name}-#{@id}"
    end

    no_commands do

      def build
        request = @request.get("/template/#{@template_name}")
        if request.status == 200
          Dir.mkdir(@@build_dir) unless File.directory?(@@build_dir)
          Dir.mkdir(@template_dir)
          build_css
          build_html(request.body)
          inline_css
          say "Build #{@template_name}-#{@id} successful.", :green
        else
          say 'Build failed. ', :red
          say "Template #{@template_name} not found."
        end
      end

      private

      def build_css
        puts "Compiling css..."
        build_css_file 'styles'
        build_css_file 'responsive'
      end

      def build_css_file(filename='styles')
        file = "./assets/css/#{@template_name}/#{filename}.scss"
        if File.file? file
          content = Tilt::ScssTemplate.new(file, style: :expanded).render
          create_file(content: content, name: filename, ext: 'css')
        else
          puts "Build failed. #{filename}.scss for #{@template_name} not found." # continues anyway
        end
      end

      def build_html(content)
        puts "Compiling html..."
        content = content.gsub("/assets/#{@template_name}/styles.css", 'styles.css')
        @html = create_file(content: content, name: @template_name, ext: 'html')
      end

      def inline_css
        puts "Inlining css..."
        markup  = File.read(@html.path)
        markup  = markup.gsub(/(<link.*responsive.css")(>)/i, '\1 data-roadie-ignore\2')
        document = Roadie::Document.new(markup)
        document.asset_providers = [
          Roadie::FilesystemProvider.new(@template_dir)
        ]
        inlined = cleanup_markup(document.transform)
        create_file(content: inlined, name: 'build', ext: 'html')
      end

      def cleanup_markup(markup)
        puts "Cleaning up markup..."
        content = use_asset_server(markup)
        content = remove_livereload(content)
        content = add_responsive_css(content)
        content
      end

      def create_file(attrs)
        content = attrs[:content]
        name    = attrs[:name]
        ext     = attrs[:ext]

        file = File.new("#{@template_dir}/#{name}.#{ext}", 'w')
        file.puts(content)
        file.close
        file
      end

      # Creates id based on current time stamp
      # e.g. 2014-08-14 15:50:25 +0200
      # becomes 20140814155025
      def create_id
        stamp = Time.now.to_s
        stamp.split(' ')[0..1].join.gsub(/(-|:)/, '')
      end

      def use_asset_server(markup = '')
        replaced = "#{@asset_server}/"
        output = markup.gsub('/assets/', replaced)
        output
      end

      def remove_livereload(markup = '')
        markup.gsub(/<script.*?>(\s|\S)*<\/script>/i, '')
              .gsub(/(<head.*?>\n)(\s*\n)*/i, '\1')
      end

      def add_responsive_css(markup = '')
        css = File.read("#{@template_dir}/responsive.css")
        css_markup = "<style type=\"text/css\">\n" + css + "</style>\n"
        markup.gsub(/<link(.*)responsive.css" data-roadie-ignore>/i, css_markup)
      end
    end
  end
end
