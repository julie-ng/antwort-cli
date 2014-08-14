require 'fileutils'
require 'securerandom'
require 'tilt'
require 'premailer'

module Antwort
  class Builder

    @@asset_server = '/assets/' #ENV['ASSET_URL'] || "foo"
    @@source_dir  = File.expand_path('./source/emails')
    @@build_dir   = File.expand_path('./build')
    @@layout_file = @@source_dir + '/layout.erb'

    def initialize(attrs={})
      @hash          = SecureRandom.hex(6)
      @template_name = attrs[:template]
      @template_dir  = "#{@@build_dir}/#{@template_name}" #-#{@hash}"
    end

    def build
      puts "Building #{@template_name}, id: #{@hash}..."
      unless Dir.exists? @template_dir
        Dir.mkdir @template_dir
      end
      @html = build_html
      @css  = build_css
      inline_template
    end

    private

      def build_css
        content = Tilt::ScssTemplate.new("source/assets/css/#{@template_name}/main.scss").render
        create_file(content: content, name: @template_name, ext: 'css')
      end

      def build_html
        context = Object.new
        attrs = {template: @template_name}
        layout = Tilt::ERBTemplate.new(@@layout_file)
        output = layout.render(context, attrs) {
          Tilt::ERBTemplate.new("#{@@source_dir}/#{@template_name}.html.erb").render(context, attrs)
        }
        output = output.gsub("/assets/styles.css", "#{@template_name}.css") # Replace absolute with relative path
        create_file(content: output, name: @template_name, ext: 'html')
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

      def inline_template
        premailer = Premailer.new(@html.path, :warn_level => Premailer::Warnings::SAFE)
        inlined   = premailer.to_inline_css
        inlined   = use_asset_server(inlined)
        create_file(content: inlined, name: 'build', ext: 'html')
      end

      def use_asset_server(markup='')
        replaced = "<img src=\"#{@@asset_server}/assets/"
        output = markup.gsub('<img src="/assets/', replaced)
        output
      end
  end
end