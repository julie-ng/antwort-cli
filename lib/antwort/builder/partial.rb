module Antwort
  class PartialBuilder < Builder
    attr_reader :templates

    def post_initialize(*)
      @templates = list_partials(source_dir) # try Antwort::CLIHelpers::list_partials later
      return if templates.length > 0
      say 'Error: ', :red
      puts "No partials found in #{template_name} folder."
    end

    def build
      @css = load_css
      templates.each { |t| build_html t }
      show_accuracy_warning
    end

    def build_html(partial_name)
      source_file = "#{source_dir}/#{partial_name}"
      source      = File.read(source_file)
      markup      = preserve_erb_code(source)
      inlined     = inline(markup)
      filename    = adjust_filename(partial_name)
      create_file(content: inlined, path: "#{build_dir}/#{filename}")
    end

    def inline(markup)
      document = Roadie::Document.new markup
      document.add_css(css)
      inlined  = document.transform
      inlined  = remove_extra_dom(inlined)
      inlined
    end

    def adjust_filename(filename)
      name = filename.gsub('.erb', '')
      name << '.html' unless name[-5, 5] == '.html'
      name
    end

    def remove_extra_dom(html = '')
      html.gsub(/\<!(.*)\<body.*?\>/im, '')
          .gsub(%r{</body>.*?</html>}im, '')
    end

    def preserve_erb_code(html = '')
      html = preserve_variables(html)
      html
    end

    def preserve_variables(html = '')
      html.gsub(/&lt;%=(.*)%&gt;/i, '{{\1}}')
          .gsub(/\<%=(.*)%\>/i, '{{\1}}')
    end

    def show_accuracy_warning
      say ''
      say '** NOTE: Accuracy of Inlinied Partials **', :yellow
      say 'Partials do not have access to the full DOM tree. Therefore, nested CSS selectors, e.g. ".layout td",'
      say 'may not be matched for inlining. Always double check your code before use in production!'
    end
  end
end
