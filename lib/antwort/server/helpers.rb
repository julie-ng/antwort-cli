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
  end

end