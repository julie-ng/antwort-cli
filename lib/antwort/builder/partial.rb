module Antwort
  class PartialBuilder < Builder

    attr_reader :templates

    def post_initialize(attrs={})
      @templates = list_partials(source_dir) #try Antwort::CLIHelpers::list_partials later
      unless templates.length > 0
        say 'Error: ', :red
        puts "No partials found in #{template_name} folder."
      end
    end

    def build
      @css = load_css
      templates.each { |t| inline(partial: "#{source_dir}/#{t}") }
      show_accuracy_warning
    end

    def inline(attrs = {})
      source_file = attrs[:partial]
      filename    = source_file.split('/').last.gsub('.erb','')
      markup      = File.read(source_file)

      document = Roadie::Document.new markup
      document.add_css(css)

      inlined  = document.transform
      inlined  = remove_extra_dom(inlined)
      inlined  = correct_erb_var_names(inlined)

      unless create_file(content: inlined, path: "#{build_dir}/#{filename}")
        say "Inline failed ", :red
        say source_file
      end
    end

    def remove_extra_dom(html='')
      html.gsub(/\<!(.*)\<body.*?\>/im,'')
          .gsub(/<\/body>.*?<\/html\>/im,'')
    end

    def correct_erb_var_names(html='')
      html.gsub(/&lt;%=(.*)%&gt;/i,'{{\1}}')
          .gsub(/\<%=(.*)%\>/i,'{{\1}}')
    end

    def show_accuracy_warning
      say ""
      say "** NOTE: Accuracy of Inlinied Partials **", :yellow
      say "Partials do not have access to the full DOM tree. Therefore, nested CSS selectors, e.g. \".layout td\","
      say "may not be matched for inlining. Always double check your code before use in production!"
    end
  end
end