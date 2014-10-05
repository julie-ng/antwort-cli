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