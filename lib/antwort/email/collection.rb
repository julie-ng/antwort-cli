module Antwort
  class EmailCollection
    include Antwort::Helpers

    attr_reader :source, :templates, :list

    def initialize(opts={})
      @source = opts[:source] || Dir.pwd
      @templates = []
      @list = []

      dir = "#{@source}/emails"
      set_collection(dir) if Dir.exists? dir
    end

    def empty?
      @templates.length === 0
    end

    private

    def set_collection(dir)
      folders = Dir.entries(dir)
      folders = filter_templates(folders)

      folders.each do |f|
        @list.push f
        @templates.push Antwort::EmailTemplate.new(f)
      end
    end

    def filter_templates(arry=[])
      arry.delete_if { |name| name.to_s[0] == '.' }
      arry.delete_if { |name| name.to_s == 'shared' }
    end
  end
end
