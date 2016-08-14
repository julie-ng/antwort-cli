module Antwort
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
        url: url
      }.merge(args)
      partial('views/markup/button', locals: options)
    end

    def counter_classes(index)
      # 0 index based
      klass = ''
      klass += index.even?      ? ' is-2n' : ''
      klass += (index % 3 == 0) ? ' is-3n' : ''
      klass += (index % 4 == 0) ? ' is-4n' : ''
      klass += (index % 6 == 0) ? ' is-6n' : ''
      klass
    end
  end
end
