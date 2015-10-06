module Antwort
  class Flattener

    attr_reader :source, :styles, :flattened, :flattened_styles

    def initialize(source='')
      @source       = source
      @styles       = set_styles
      @is_flattened = false
      self
    end

    def flatten
      flatten_styles
      flatten_source
      self
    end

    def flattened?
      @is_flattened
    end

    private

      def set_styles
        styles = []
        @source.scan(/style="(.+?)"/).each { |s| styles.push(s.first) }
        styles
      end

      def flatten_source
        flat = String.new(@source)
        @styles.each_with_index do |style, i|
          unless styles[i] == flattened_styles[i]
            flat.sub!(styles[i], flattened_styles[i])
            @is_flattened = true
          end
        end
        @flattened = flat
      end

      def flatten_styles
        flattened = []
        @styles.each { |m| flattened.push flatten_str(m) }
        @flattened_styles = flattened
      end

      def flatten_str(str)
        hash_to_str( str_to_hash(str) )
      end

      # split styles and save them to a hash,
      # automatically overriding repeat attributes
      def str_to_hash(str)
        h = Hash.new
        str.split(';').each { |s| h[s.split(':').first.strip] = s.split(':').last.strip }
        h
      end

      # convert our flatted styles hash back into a string
      def hash_to_str(hash)
        str = ''
        hash.each { |k,v| str << "#{k}:#{v};" }
        str.chop! if str[-1] == ';' # remove trailing ';'
        str
      end
  end
end
