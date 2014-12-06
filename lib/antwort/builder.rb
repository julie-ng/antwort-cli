require 'fileutils'
require 'tilt'
require 'roadie'
require_relative 'cli/helpers'

module Antwort
  class Builder < Thor
    include Antwort::CLIHelpers
    attr_reader :build_id, :template_name, :build_partials, :build_dir, :source_markup_dir, :source_scss_dir, :destination_dir

    @@build_dir = File.expand_path('./build')

    def initialize(attrs = {})
      @build_id       = create_id_from_timestamp
      @build_partials = attrs[:partials]
      @template_name  = attrs[:email]

      @asset_server  = ENV['ASSET_SERVER'] || '/assets/'

      set_build_directories
    end

    no_commands do

      def set_build_directories
        @build_dir          = build_partials? ? "#{@@build_dir}/partials" : @@build_dir
        @source_markup_dir  = "./emails/#{template_name}"
        @source_scss_dir    = "./assets/css/#{template_name}/"
        @destination_dir    = "#{build_dir}/#{template_name}-#{build_id}"
      end

      def build(attrs = {})
        if build_partials?
          build_partial_templates
        else
          build_email
        end
      end

      def build_email
        @app     ||= Antwort::Server.new
        @request ||= Rack::MockRequest.new(@app)

        request = @request.get("/template/#{template_name}")
        if request.status == 200
          create_build_directories
          build_css
          build_html(request.body)
          inline_css
          say "Build #{@template_name}-#{build_id} successful.", :green
        else
          say "Build '#{@template_name}' failed.", :red
          say "If the template exists, verify that the Antwort server can render the template."
        end
      end

      def build_partials?
        build_partials == true
      end

      def build_partial_templates
        templates = list_partials(source_markup_dir)

        if templates.length > 0
          create_build_directories
          scss = "#{source_scss_dir}/styles.scss"
          css  = "#{destination_dir}/styles.css"
          compile_css(source: scss, destination: css)
          templates.each { |t| inline_partial(partial: "#{source_markup_dir}/#{t}", css: css) }
          say ""
          say "** NOTE: Accuracy of Inlinied Partials **", :yellow
          say "Partials do not have access to the full DOM tree. Therefore, nested CSS selectors, e.g. \".layout td\","
          say "may not be matched for inlining. Always double check your code before use in production!"
        else
          puts "No partials found in #{folder}."
        end
      end

      private

      def create_build_directories
        # Create parent 'build' folder if it doesn't exist
        Dir.mkdir(@@build_dir) unless File.directory?(@@build_dir)

        Dir.mkdir(build_dir) unless File.directory?(build_dir)
        Dir.mkdir(destination_dir)
        Dir.mkdir("#{destination_dir}/source") unless build_partials?
      end

      def build_css
        puts "Compiling css..."
        dest = "#{destination_dir}/source"
        compile_css(source: "#{source_scss_dir}/styles.scss", destination: "#{dest}/styles.css")
        compile_css(source: "#{source_scss_dir}/responsive.scss", destination: "#{dest}/responsive.css")
      end

      def compile_css(attrs={})
        source_file      = attrs[:source]
        destination_file = attrs[:destination]

        if File.file? source_file
          content = Tilt::ScssTemplate.new(source_file, style: :expanded).render
          create_file(content: content, path: destination_file)
        else
          puts "Build failed. #{filename}.scss for #{template_name} not found." # continues anyway
        end
      end

      def build_html(content)
        puts "Compiling html..."
        content = content.gsub("/assets/#{template_name}/styles.css", 'styles.css')
                         .gsub("/assets/#{template_name}/responsive.css", 'responsive.css')
        content = remove_livereload(content)
        @html = create_file(content: content, path: "#{destination_dir}/source/#{template_name}.html")
      end

      def inline_css
        puts "Inlining css..."
        markup  = File.read(@html.path)
        markup  = markup.gsub(/(<link.*responsive.css")(>)/i, '\1 data-roadie-ignore\2')
        document = Roadie::Document.new(markup)
        document.asset_providers = [
          Roadie::FilesystemProvider.new("#{destination_dir}/source")
        ]
        inlined = cleanup_markup(document.transform)
        create_file(content: inlined, path: "#{destination_dir}/inlined.html")
      end

      def inline_partial(attrs = {})
        css_file    = attrs[:css]
        source_file = attrs[:partial]
        filename    = source_file.split('/').last

        markup   = File.read(source_file)
        css      = File.read(css_file)
        document = Roadie::Document.new markup
        document.add_css(css)
        inlined  = document.transform
        inlined  = remove_extra_dom(inlined)
        inlined  = correct_erb_var_names(inlined)

        if create_file(content: inlined, path: "#{destination_dir}/#{filename}")
          say "Inline ", :green
        else
          say "Inline failed ", :red
        end
        say source_file
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
        path    = attrs[:path]

        file = File.new(path, 'w')
        file.write(content)
        file.close
        file
      end

      # Creates id based on current time stamp
      # e.g. 2014-08-14 15:50:25 +0200
      # becomes 20140814155025
      def create_id_from_timestamp
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
        css = File.read("#{destination_dir}/source/responsive.css")
        css_markup = "<style type=\"text/css\">\n" + css + "</style>\n"
        markup.gsub(/<link(.*)responsive.css" data-roadie-ignore>/i, css_markup)
      end

      def remove_extra_dom(html='')
        html.gsub(/\<!(.*)\<body style="margin:0;padding:0"\>/im,'')
            .gsub(/\n<\/body>(.*)/im,'')
      end

      def correct_erb_var_names(html='')
        html.gsub(/&lt;%=(.*)%&gt;/i,'{{\1}}')
            .gsub(/\<%=(.*)%\>/i,'{{\1}}')
      end
    end
  end
end
