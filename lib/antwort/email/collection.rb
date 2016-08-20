module Antwort
  class EmailCollection
    include Antwort::Helpers
    include Antwort::FileHelpers

    attr_reader :templates, :list

    def initialize
      @templates = []
      @list = []

      dir = './emails'
      find_templates(dir) if Dir.exist? dir
    end

    def empty?
      @templates.empty?
    end

    def total
      @templates.length
    end

    private

    def find_templates(dir)
      folders = Dir.entries(dir)
      folders = filter_templates(folders)

      folders.each do |f|
        @list.push f
        @templates.push Antwort::EmailTemplate.new(f)
      end
    end

    def filter_templates(arry = [])
      arry.delete_if { |name| name.to_s[0] == '.' }
      arry.delete_if { |name| name.to_s == 'shared' }
    end
  end
end
