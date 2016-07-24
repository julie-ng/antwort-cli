module Antwort
  module Helpers
    def symbolize_keys!(hash)
      hash.reduce({}) do |result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys!(value)
                    when Array then value.map { |v| v.is_a?(Hash) ? symbolize_keys!(v) : v }
                    else value
                    end
        result[new_key] = new_value
        result
      end
    end

    def load_yaml_data(file='')
      data = {}
      if File.file? file
        data = YAML.load_file(file)
        data = symbolize_keys! data if data
      end
      data
    end
  end
end