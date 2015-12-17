module Antwort
  module MarkupSanitizers

    def remove_livereload(markup = '')
      markup.gsub(/<script.*?>(\s|\S)*<\/script>/i, '')
            .gsub(/(<head.*?>\n)(\s*\n)*/i, '\1')
    end

    def add_included_css(markup = '')
      css = File.read("#{markup_dir}/include.css")
      css_markup = "</title>\n<style type=\"text/css\">\n" + css + "</style>\n"
      markup.gsub(%r{</title>}i, css_markup)
    end

    def remove_roadie_flags(markup = '')
      markup.gsub(' data-roadie-ignore', '')
    end

    def remove_excessive_newlines(markup = '')
      markup.gsub(/^([ \t]*\n){3,}/m, "\n\n")
    end

    def remove_extra_dom(html = '')
      html.gsub(/\<!(.*)\<body.*?\>/im, '')
          .gsub(%r{</body>.*?</html>}im, '')
    end

  end
end