module Antwort

  module ApplicationHelpers

    def symbolize_keys!(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys!(value)
                    when Array then value.map{ |v| v.is_a?(Hash) ? symbolize_keys!(v) : v }
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end

    def sanitize_param(string)
      string.nil? ? '' : string.gsub(/([^A-Za-z0-9_\/-]+)|(--)/, '_')
    end
  end

  module MarkupHelpers

    def image_tag(path, options={})
      @template ||= ''
      subdir = path.split('/').first == 'shared' ? '' :  @template + '/'
      options[:source] = '/assets/' + subdir + path
      options[:alt] ||= ''
      content = partial :'views/markup/image_tag', locals: options
      content.gsub(/\n/, '')
    end

    def button(text, url, args={})
      options = {
        text: text,
        url: url,
        background_color: '#0095DA',
        border_color: '#007FB9',
        border_radius: '4px',
        width: 200,
        height: 40,
        font_size: '16px'
      }.merge(args)

      options[:width]  = options[:width].to_s
      options[:height] = options[:height].to_s
      options[:width]  += 'px' if options[:width][-2..-1] != 'px'
      options[:height] += 'px' if options[:height][-2..-1] != 'px'

      content = partial :'views/markup/button', locals: options
      content
    end

    def wrapper_table(args={}, &block)
      options = {
        width: '100%',
        cell_align: 'center',
        cell_valign: 'top',
        content: capture_html(&block)
      }.merge(args)
      content = partial :'views/markup/table_wrapper', locals: options
      concat_content content
    end

    def counter_classes(index)
      # 0 index based
      klass = ''
      klass += (index%2 == 0) ? ' is-2n' : ''
      klass += (index%3 == 0) ? ' is-3n' : ''
      klass += (index%4 == 0) ? ' is-4n' : ''
      klass += (index%6 == 0) ? ' is-6n' : ''
      klass
    end

  end

end