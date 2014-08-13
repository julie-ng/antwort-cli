require 'fileutils'
require 'securerandom'
require 'tilt'
require 'premailer'

module Antwort
  class Builder

    # @@dir = File.dirname(__FILE__)
    @@build_dir =  File.expand_path('./build')


    def initialize(attrs={})
      puts "Initalizing Builder..."

      @hash          = SecureRandom.hex(6)
      @template_name = attrs[:template]
      @template_dir  = "#{@@build_dir}/#{@template_name}-#{@hash}"
    end


    def build


    end

    def build_template(template_name)

      Dir.mkdir template_dir

      puts "-- Building #{template_name}-#{hash} --"
      puts ""

      create_css_file template_name, template_dir
      markup = create_html_file template_name, template_dir
      create_output_file markup, template_dir
    end

    def create_output_file(html_file, template_dir)
      premailer = Premailer.new(html_file.path, :warn_level => Premailer::Warnings::SAFE)
      markup = replace_asset_url premailer.to_inline_css
      create_file(markup, 'output', 'html', template_dir)
    end

    def replace_asset_url(markup='')
      url = ENV['ASSET_URL']
      replaced = "<img src=\"#{url}/assets/"
      output = markup.gsub('<img src="/assets/', replaced)
      output
    end

    def create_html_file(template_name, dir)
      context = Object.new
      attrs = {template: template_name}
      layout = Tilt::ERBTemplate.new("views/layouts/layout.erb")
      output = layout.render(context, attrs) {
        Tilt::ERBTemplate.new("views/#{template_name}.html.erb").render(context, attrs)
      }
      output = output.gsub("/assets/#{template_name}/styles.css", "#{template_name}.css")
      create_file(output, template_name, 'html', dir)
    end

    def create_css_file(template_name, dir)
      styles = Tilt::ScssTemplate.new("assets/css/#{template_name}/styles.scss").render
      create_file(styles, template_name, 'css', dir)
    end



    private

      def create_file(content, name='design', ext='html', path)
        file = File.new("#{path}/#{name}.#{ext}", "w")
        file.puts(content)
        file.close
        file
      end

    # # Todo - render markup
    # def partial(foo)
    #   puts "partial: #{foo}"
    # end

  end
end