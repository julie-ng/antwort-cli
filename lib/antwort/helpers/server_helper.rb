module Antwort
  module ApplicationHelpers

    def sanitize_param(string)
      string.nil? ? '' : string.gsub(/([^A-Za-z0-9_\/-]+)|(--)/, '_')
    end

    def template_exists?(template_name)
      File.file? settings.templates_dir + '/' + template_name + '/index.html.erb'
    end

    def template_from_path
      request.path_info.gsub(%r{/template/}i, '')
    end

    def hash_to_instance_vars(data)
      data.each { |k, v| instance_variable_set("@#{k}", v) } if data
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
