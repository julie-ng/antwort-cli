module Antwort
  module MarkupHelpers
    def image_tag(path, opts = {})
      locals = {
        source: image_url_from_path(path)
      }.merge!(opts)
      render_markup('image_tag', locals).delete("\n")
    end

    def button(text, url, opts = {})
      locals = {
        text: text,
        url: url
      }.merge(opts)
      render_markup('button', locals)
    end

    def markup_views
      File.expand_path('../server/views/markup', File.dirname(__FILE__))
    end

    def render_markup(template, locals)
      scope = OpenStruct.new
      Tilt::ERBTemplate.new("#{markup_views}/#{template}.html.erb").render(scope, locals)
    end

    def counter_classes(index)
      # 0 index based
      klass = ''
      klass += index.even? ? ' is-2n' : ''
      klass += (index % 3).zero? ? ' is-3n' : ''
      klass += (index % 4).zero? ? ' is-4n' : ''
      klass += (index % 6).zero? ? ' is-6n' : ''
      klass
    end
  end
end
