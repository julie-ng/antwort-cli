module Antwort
  class EmailBuilder < Builder
    attr_accessor :html_markup

    def post_initialize(*)
      app     ||= Antwort::Server.new
      mock    ||= Rack::MockRequest.new(app)
      @request  = mock.get("/template/#{template.name}")

      if template_is_valid?
        create_build_directories!
        @html_markup  = remove_livereload(@request.body)
        @inlined_file = "#{build_dir}/#{template.name}.html"
      else
        show_error_message
      end
    end

    def build!
      unless html_markup.nil?
        build_css!
        build_html!
        inline_css!
      end

      sleep 1 until File.exist?(@inlined_file)
      true
    end

    def build_html!
      markup = html_markup
      markup = markup.gsub("/assets/#{template.name}/inline.css", 'inline.css')
                     .gsub("/assets/#{template.name}/include.css", 'include.css')
      create_file!(content: markup, path: "#{markup_dir}/#{template.name}.html")
    end

    def inline_css!
      markup   = preserve_nbsps(html_markup)
      document = Roadie::Document.new(markup)

      document.asset_providers << Roadie::NullProvider.new
      document.add_css(css)

      inlined = restore_nbsps(document.transform)
      inlined = cleanup_markup(inlined)
      inlined = remove_roadie_flags(inlined)
      inlined = remove_excessive_newlines(inlined)
      inlined = flatten_inlined_css(inlined)
      create_file!(content: inlined, path: @inlined_file)
    end

    def cleanup_markup(markup)
      content = use_asset_server(markup)
      content = add_included_css(content)
      content
    end

    private

    def show_error_message
      msg = if template_not_found?
              "Template '#{template.name}' not found."
            elsif template_has_error?
              "Template '#{template.name}' is not rendering succesfully. Verify with `antwort server` that the template is valid and try again."
            else
              "Error building #{template.name}."
            end

      say 'Error: ', :red
      say msg
      exit
    end

    def template_is_valid?
      @request.status == 200
    end

    def template_not_found?
      @request.status == 404
    end

    def template_has_error?
      @request.status == 500
    end
  end
end
