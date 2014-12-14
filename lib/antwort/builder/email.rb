module Antwort
  class EmailBuilder < Builder
    attr_accessor :html_markup

    def post_initialize(*)
      app     ||= Antwort::Server.new
      mock    ||= Rack::MockRequest.new(app)

      request = mock.get("/template/#{template_name}")
      if request.status == 200
        @html_markup = remove_livereload(request.body)
      else
        say 'Error: ', :red
        say "Template #{template_name} invalid."
        say 'If the template exists, verify that the Antwort server can render the template.'
      end
    end

    def build
      build_css
      build_html
      inline_css
    end

    def build_html
      markup = html_markup
      markup = markup.gsub("/assets/#{template_name}/styles.css", 'styles.css')
                     .gsub("/assets/#{template_name}/responsive.css", 'responsive.css')
      html_markup = markup
      create_file(content: html_markup, path: "#{markup_dir}/#{template_name}.html")
    end

    def inline_css
      document = Roadie::Document.new(html_markup)
      document.asset_providers << Roadie::NullProvider.new
      document.add_css(css)
      inlined = cleanup_markup(document.transform)
      create_file(content: inlined, path: "#{build_dir}/#{template_name}.html")
    end

    def cleanup_markup(markup)
      content = use_asset_server(markup)
      content = add_responsive_css(content)
      content
    end

    def remove_livereload(markup = '')
      markup.gsub(/<script.*?>(\s|\S)*<\/script>/i, '')
            .gsub(/(<head.*?>\n)(\s*\n)*/i, '\1')
    end

    def add_responsive_css(markup = '')
      css = File.read("#{markup_dir}/responsive.css")
      css_markup = "<style type=\"text/css\">\n" + css + "</style>\n"
      markup.gsub(/<link(.*)responsive.css" data-roadie-ignore>/i, css_markup)
    end
  end
end
