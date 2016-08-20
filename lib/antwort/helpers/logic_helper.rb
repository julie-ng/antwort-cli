module Antwort
  module LogicHelpers
    def preserve_nbsps(html = '')
      html.gsub(/&nbsp;/, '%nbspace%')
    end

    def restore_nbsps(html = '')
      html.gsub(/%nbspace%/, '&nbsp;')
    end

    def preserve_logic(html = '')
      html = preserve_comments(html)
      html = preserve_conditionals(html) # conditionals before loops, in case we have them inside loops
      html = preserve_loops(html)
      html = preserve_variables(html)
      html = preserve_assignments(html)
      html = convert_partials_to_includes(html)
      html = convert_helper_wrappers(html)
      html = preserve_leftover_statements(html) # must be last
      html
    end

    def preserve_conditionals(html = '')
      html.gsub(/<%\s*if (.*?)%>/, '{% if \1 %}')         # if
          .gsub(/<%\s*unless (.*?)%>/, '{% if !( \1) %}') # unless
          .gsub(/<%\s*elsif(.*?)%>/, '{% elseif\1%}')     # elsif
          .gsub(/<%\s*else\s*%>/, '{% else %}')           # else
          .gsub(/<%\s*end\s*%>/, '{% end %}')             # end
          .gsub(/[ \t]{2,}%}/, ' %}') # remove extra white space, e.g. {% else    %}
    end

    def preserve_loops(html = '')
      html.gsub(/<%\s+(.*)(\.each\s+do\s+\|)\s*(\S+)\s*(\|\s+)%>/, '{% for \3 in \1 %}')
          .gsub(/<%\s+(.*)(\.each_with_index\s+do\s+\|)\s*(\S+)\s*,\s*(\S+)\s*(\|\s+)%>/, '{% for \3 in \1 with: {@index: \4} %}')
          .gsub(/<%\s*end\s*%>/, '{% end %}')
    end

    def preserve_comments(html = '')
      html.gsub(/<%[ \t]*#(.*)%>/, '{#\1#}')
          .gsub(/{#([^=\s])/, '{# \1')      # {#foo #} ->{# foo #}
    end

    def preserve_variables(html = '')
      html.gsub(/\[:(.*?)\]/, '.\1')        # a[:b][:c] -> a.b.c
          .gsub(/\['(.*?)'\]/, '.\1')       # a['b'] -> a.b
          .gsub(/\["(.*?)"\]/, '.\1')       # a["b"] -> a.b
          .gsub(/<%=(.*?)%>/, '{{\1}}') # assume leftover erb output are variables
    end

    def preserve_assignments(html = '')
      html.gsub(/<%\s+([A-Za-z0-9_]+)\s*(\|\|=)\s*(.*)\s+%>/, '{% set \1 = \1 || \3 %}')
          .gsub(/<%\s+([A-Za-z0-9_]+)\s*(=)\s*(.*)\s+%>/, '{% set \1 = \3 %}')
    end

    def preserve_leftover_statements(html = '')
      html.gsub(/<%\s*(.*?)?%>/, '{% \1%}') # no trailing space because group captures it
    end

    def restore_variables_in_links(html = '')
      html.gsub('%7B%7B%20', '{{ ')
          .gsub('%20%7D%7D', ' }}')
    end

    def convert_partials_to_includes(html = '')
      html.gsub(/{{ partial :(.+?) }}/, '{% include \1 %}')
          .gsub(/{% include (.+),\s+locals:(.+?)%}/, '{% include \1 with:\2%}')
          .gsub(/(<%=\s+?partial\s+?:)(.+?),(.+?)(locals:)((.|\n)+?)(%>)/, '{% include \2 with:\5%}') # multiline partials not caught in presumably leftover variable
    end

    def convert_helper_wrappers(html = '')
      html.gsub(/{{ button(.+?)}}/, '{% button\1%}')
          .gsub(/{{ image_tag(.+?)}}/, '{% image_tag\1%}')
    end

    def cleanup_logic(html = '')
      html.gsub(/({%|{{)(.*?)(&lt;)(.*?)(}}|%})/, '\1\2<\4\5') # <
          .gsub(/({%|{{)(.*?)(&gt;)(.*?)(}}|%})/, '\1\2>\4\5') # >
          .gsub(/&amp;&amp;/, '&&')
    end
  end
end
