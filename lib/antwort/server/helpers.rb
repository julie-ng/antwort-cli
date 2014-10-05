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
      get_metadata(template_name)['title'] || 'Untitled'
    end

    def get_metadata(template_name)
      get_content(template_name)[:metadata]
    end

    def get_content(template_name)
      file = get_template_file(template_name)
      data = File.read(file)
      md = data.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m)
      return {
        body:     (md.nil?) ? data : md.post_match,
        metadata: (md.nil?) ? {} : YAML.load(md[:metadata])
      }
    end

    def fetch_data(template_name)
      data_file = settings.root + '/data/' + template_name + '.yml'
      if File.file? data_file
        data = YAML.load_file(data_file)
        data = symbolize_keys! data
      else
        data = {}
      end
      data
    end

    def template_exists?(template_name)
      File.file? settings.templates_dir + '/' + template_name + '/index.html.erb'
    end

    def get_template_from_path
      request.path_info.gsub(/\/template\//i,'')
    end

    def render_template(erb_markup, args = {})
      opts = {
        data: {},
        context: Object.new,
        layout: 'layout'
      }.merge(args)

      template = Tilt['erb'].new { erb_markup }
      opts[:data].each { |k,v| instance_variable_set("@#{k}", v) }

      if opts[:layout]
        layout = Tilt::ERBTemplate.new("#{settings.views}/views/#{opts[:layout]}.erb")
        layout.render(opts[:context]) {
          template.render(opts[:context])
        }
      else
        template.render(opts[:context])
      end
    end

    def image_url_from_path(path)
      p = path.split(':')[0]
      if (p == 'http' || p == 'https')
        url = path
      else
        a = [path]
        a.unshift(get_template_from_path) unless path[0] == '/'
        a.unshift('/assets')
        url = File.join(a)
      end
      url
    end

  end

  module MarkupHelpers
    def image_tag(path, options = {})
      options[:source] = image_url_from_path(path)
      options[:alt] ||= ''
      partial('views/markup/image_tag', locals: options)
        .gsub(/\n/, '')
    end

    def button(text, url, args = {})
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

      partial('views/markup/button', locals: options)
    end

    def wrapper_table(args = {}, &block)
      options = {
        width: '100%',
        cell_align: 'center',
        cell_valign: 'top',
        content: capture_html(&block)
      }.merge(args)

      concat_content partial('views/markup/table_wrapper', locals: options)
    end

    def counter_classes(index)
      # 0 index based
      klass = ''
      klass += (index % 2 == 0) ? ' is-2n' : ''
      klass += (index % 3 == 0) ? ' is-3n' : ''
      klass += (index % 4 == 0) ? ' is-4n' : ''
      klass += (index % 6 == 0) ? ' is-6n' : ''
      klass
    end
  end
end
