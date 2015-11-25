module Antwort
  module LogicHelpers

    def preserve_nbsps(html = '')
      html.gsub(/&nbsp;/, '%nbspace%')
    end

    def restore_nbsps(html = '')
      html.gsub(/%nbspace%/, '&nbsp;')
    end

    def preserve_erb_code(html = '')
      html = preserve_comments(html)
      html = preserve_conditionals(html) # conditionals before loops, in case we have them inside loops
      html = preserve_loops(html)
      html = preserve_variables(html)
      html = preserve_assignments(html)
      html
    end

    def preserve_conditionals(html = '')
      html.gsub(%r{<%\s*if (.*?)%>([\s\S]*?)(<%\s*end\s*%>)}, '{% if \1 %}\2{% endif %}') # opening if and closing end
          .gsub(%r{<%\s*elsif(.*?)%>}, '{% elseif\1%}') # now match conditionals in between
          .gsub(%r{<%\s*else\s*%>}, '{% else %}')
          .gsub(/[ \t]{2,}%}/, ' %}') # remove extra white space, e.g. {% else    %}
    end

    def preserve_loops(html = '')
      html.gsub(%r{<%\s+(.*)(\.each\s+do\s+\|)\s*(\S+)\s*(\|\s+)%>}, '{% for \3 in \1 %}')
          .gsub(%r{<%\s+(.*)(\.each_with_index\s+do\s+\|)\s*(\S+)\s*,\s*(\S+)\s*(\|\s+)%>}, '{% for \3 in \1 %}')
          .gsub(%r{<%\s+end\s+%>}, '{% endfor %}')
    end

    def preserve_comments(html = '')
      html.gsub(%r{<%[ \t]*#(.*)%>},'{#\1#}')
          .gsub(/{#([^=\s])/, '{# \1')          # {#foo #} ->{# foo #}
    end

    def preserve_variables(html = '')
      html.gsub(/\[:(.*?)\]/, '.\1')        # a[:b][:c] -> a.b.c
          .gsub(/\['(.*?)'\]/, '.\1')       # a['b'] -> a.b
          .gsub(/\["(.*?)"\]/, '.\1')       # a["b"] -> a.b
          .gsub(%r{<%=(.*?)%>}, '{{\1}}')   # assume leftover erb output are variables
    end

    def preserve_assignments(html = '')
      html.gsub(%r{<%\s+([A-Za-z0-9_]+)\s*(\|\|=)\s*(.*)\s+%>}, '{% set \1 = \1 || \3 %}')
          .gsub(%r{<%\s+([A-Za-z0-9_]+)\s*(=)\s*(.*)\s+%>}, '{% set \1 = \3 %}')
    end

    def restore_variables_in_links(html = '')
      html.gsub('%7B%7B%20','{{ ')
          .gsub('%20%7D%7D',' }}')
    end

    def cleanup_logic(html = '')
      html.gsub(/&gt;=/, '>=')
          .gsub(/&lt;=/, '<=')
          .gsub(/&gt;=/, '>=')
          .gsub(/&amp;&amp;/, '&&')
    end

  end
end