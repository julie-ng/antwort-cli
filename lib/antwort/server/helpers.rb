module Antwort
  module MarkupHelpers
    def image_tag(path, options={})
      options[:source] = '/assets/' << path
      options[:alt] ||= ''
      content = partial :'views/markup/image_tag', locals: options
      content.gsub(/\n/, '')
    end
  end
end