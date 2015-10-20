module Antwort
  class Flattener

    attr_reader :source, :styles, :flattened, :flattened_keys

    def initialize(source='')
      @source = source
      @styles = find_styles
      @flattened_keys = []
      self
    end

    def flatten
      copy = String.new(@source)
      @styles.each do |m|
        style = Antwort::Style.new(m)
        @flattened_keys.concat(style.duplicate_keys) if style.duplicates?
        copy.sub!(m, style.flattened_str) # flattened_str removes extra spaces and trailing semicolons
      end

      @flattened = copy
      self
    end

    def flattened?
      @flattened_keys.length > 0
    end

    private

      def find_styles
        a = []
        @source.scan(/style="(.+?)"/).each { |match| a.push(match.first) } # first is regex group `(.+?)`
        a
      end
  end
end
