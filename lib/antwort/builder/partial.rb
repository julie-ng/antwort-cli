module Antwort
  class PartialBuilder < Builder
    attr_reader :partials

    def post_initialize(*)
      @partials = @template.partials.push('index.html.erb')

      if partials.length < 1
        say 'Error: ', :red
        puts "No partials found in #{template.name} folder."
        return
      else
        create_build_directories!
      end
    end

    def build!
      @css = load_css
      partials.each { |t| build_html t }
    end

    def build_html(partial_name)
      source_file = "#{source_dir}/#{partial_name}"
      source      = File.read(source_file)
      markup      = preserve_logic(source)
      markup      = preserve_nbsps(markup)
      markup      = preserve_operators_from_nokogiri(markup)
      inlined     = inline(markup)
      inlined     = restore_nbsps(inlined)
      inlined     = flatten_inlined_css(inlined)
      filename    = adjust_filename(partial_name)
      create_file!(content: inlined, path: "#{build_dir}/#{filename}")
    end

    def inline(markup)
      # Force a complete DOM tree before inlining for nokogiri
      # Otherwise we have random <p> at beginning of document
      html = add_nokogiri_wrapper(markup)

      document = Roadie::Document.new html
      document.add_css(css)
      inlined  = document.transform
      inlined  = cleanup(inlined)

      remove_nokogiri_wrapper(inlined)
    end

    def adjust_filename(filename)
      filename = @template.name if filename == 'index.html.erb'

      name = filename.gsub('.erb', '')
      name << '.html' unless name[-5, 5] == '.html'
      name = '_' << name unless name[0] == '_'
      name
    end

    def cleanup(html = '')
      code = remove_extra_dom(html)
      code = cleanup_logic(code)
      code = restore_variables_in_links(code)
      code
    end

    private

    def add_nokogiri_wrapper(html = '')
      html = '<div id="valid-dom-tree">' + html + '</div><!--/#valid-dom-tree-->'
      html
    end

    def remove_nokogiri_wrapper(html = '')
      html.gsub('<div id="valid-dom-tree">', '')
          .gsub(%r{</div>(\s*)<!--/#valid-dom-tree-->}, '')
    end

    def preserve_operators_from_nokogiri(html = '')
      html.gsub(%r{{%\s*if(.*?)<(.*?)%}}, '{%\1&lt;\2%}')
          .gsub(%r{{%\s*if(.*?)>(.*?)%}}, '{%\1&gt;\2%}')
    end
  end
end
