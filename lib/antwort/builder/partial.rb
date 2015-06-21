module Antwort
  class PartialBuilder < Builder
    attr_reader :templates

    def post_initialize(*)
      @templates = list_partials(source_dir) # try Antwort::CLIHelpers::list_partials later
      if templates.length < 1
        say 'Error: ', :red
        puts "No partials found in #{template_name} folder."
        return
      else
        create_build_directories
      end
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
      markup      = preserve_nbsps(markup)
      inlined     = inline(markup)
      inlined     = restore_nbsps(inlined)
      filename    = adjust_filename(partial_name)
      create_file(content: inlined, path: "#{build_dir}/#{filename}")
    end

    def inline(markup)
      document = Roadie::Document.new markup
      document.add_css(css)
      inlined  = document.transform
      inlined  = cleanup(inlined)
      inlined
    end

    def adjust_filename(filename)
      name = filename.gsub('.erb', '')
      name << '.html' unless name[-5, 5] == '.html'
      name
    end

    def cleanup(html = '')
      code = remove_extra_dom(html)
      code = cleanup_logic(code)
      code
    end

    def remove_extra_dom(html = '')
      html.gsub(/\<!(.*)\<body.*?\>/im, '')
          .gsub(%r{</body>.*?</html>}im, '')
    end

    def cleanup_logic(html = '')
      html.gsub(/&gt;=/, '>=')
          .gsub(/&lt;=/, '<=')
          .gsub(/&gt;=/, '>=')
          .gsub(/&amp;&amp;/, '&&')
    end

    def preserve_erb_code(html = '')
      html = preserve_comments(html)
      html = preserve_conditionals(html) # conditionals before loops, in case we have them inside loops
      html = preserve_loops(html)
      html = preserve_variables(html)
      html = preserve_assignemnts(html)
      html
    end

    def preserve_conditionals(html = '')
      html.gsub(%r{<%\s*else\s*%>}, '{% else %}')
          .gsub(%r{<%\s*if (.*)%>([\s\S]*?)(<%\s*end\s*%>)}, '{% if \1 %}\2{% endif %}')
          .gsub(%r{<%\s*elsif(.*)\s*%>}, '{% bah! \1 %}')
          .gsub('  %}', ' %}')
    end

    def preserve_loops(html = '')
      html.gsub(%r{<%\s+(.*)(\.each\s+do\s+\|)(.*)(\|\s+)%>}, '{% for \3 in \1 %}')
          .gsub(%r{<%\s+end\s+%>}, '{% endfor %}')
    end

    def preserve_comments(html = '')
      html.gsub(%r{<%#(.*)%>},'{#\1#}')
    end

    def preserve_variables(html = '')
      html.gsub(/#\{(.*?)\}/, '{{ \1 }}')   # string interpolated
          .gsub(/\[:(.*?)\]/, '.\1')        # a[:b][:c] -> a.b.c
          .gsub(%r{<%=(.*?)%>}, '{{\1}}')   # assume leftover erb output are variables
    end

    def preserve_assignemnts(html = '')
      html.gsub(%r{<%\s+([A-Za-z0-9_]+)\s*(=)\s*(.*)\s+%>}, '{% set \1 = \3 %}')
    end

    def show_accuracy_warning
      say ''
      say '** NOTE: Accuracy of Inlinied Partials **', :yellow
      say 'Partials do not have access to the full DOM tree. Therefore, nested CSS selectors, e.g. ".layout td",'
      say 'may not be matched for inlining. Always double check your code before use in production!'
    end
  end
end
