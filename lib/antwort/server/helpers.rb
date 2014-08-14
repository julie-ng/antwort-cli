module Antwort
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