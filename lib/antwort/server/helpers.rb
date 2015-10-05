module Antwort
  module ApplicationHelpers
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

    def sanitize_param(string)
      string.nil? ? '' : string.gsub(/([^A-Za-z0-9_\/-]+)|(--)/, '_')
    end

    def get_template_file(template_name)
      # Dir.entries("your/folder").select {|f| !File.directory? f}
      "#{settings.views}/emails/#{template_name}/index.html.erb"
    end

    def get_page_title(template_name)
      get_metadata(template_name)[:title] || 'Untitled'
    end

    def get_metadata(template_name)
      read_template(template_name)[:metadata]
    end

    def read_template(template_name)
      file = get_template_file(template_name)

      data = File.read(file)
      md = data.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m)
      {
        body:     (md.nil?) ? data : md.post_match,
        metadata: (md.nil?) ? {} : symbolize_keys!(YAML.load(md[:metadata]))
      }
    end

    def fetch_data_yaml(template_name)
      data = {}
      data_file = settings.root + '/data/' + template_name + '.yml'
      if File.file? data_file
        data = YAML.load_file(data_file)
        data = symbolize_keys! data if data
      end
      data
    end

    def template_exists?(template_name)
      File.file? settings.templates_dir + '/' + template_name + '/index.html.erb'
    end

    def template_from_path
      request.path_info.gsub(%r{/template/}i, '')
    end

    def hash_to_instance_vars(data)
      data.each { |k, v| instance_variable_set("@#{k}", v) } unless data.empty?
    end

    def image_url_from_path(path)
      p = path.split(':')[0]
      if (p == 'http' || p == 'https')
        url = path
      else
        a = [path]
        a.unshift(template_from_path) unless path[0] == '/'
        a.unshift('/assets')
        url = File.join(a)
      end
      url
    end
  end
end
