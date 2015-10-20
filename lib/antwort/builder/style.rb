module Antwort
  class Style
    attr_reader :keys, :duplicate_keys, :flattened, :original

    def initialize(style = '')
      @style         = style
      @keys           = []
      @duplicate_keys = []
      @flattened      = []
      @original       = []

      convert_to_hash

      self
    end

    def original_str
      @style
    end

    def flattened_str
      hash_to_str @flattened
    end

    def duplicates?
      @duplicate_keys.length > 0
    end

    private

      def convert_to_hash
        str  = String.new(@style)
        h    = Hash.new
        keys = Array.new

        str.split(';').each do |s|
          key = s.split(':').first.strip
          val = s.split(':').last.strip
          h[key] = val
          @original << { key => val }

          if @keys.include? key
            @duplicate_keys << key
          else
            @keys << key
          end
        end
        @flattened = h
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