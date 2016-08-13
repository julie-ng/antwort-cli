module Antwort
  module FileHelpers

    def count_files(dir)
      Dir[File.join(dir, '**', '*')].count { |f| File.file? f }
    end

    def list_folders(folder_name)
      path = File.expand_path(folder_name)
      Dir.entries(path).select { |f| !f.include? '.' }
    end

    def email_id_from_folder_name(name)
      name.split('-')[0..-2].join('-')
    end

    def create_file!(opts)
      path = opts[:path]
      content = opts[:content]
      file = File.new(path, 'w')
      file.write(content)
      file.close
      say '    create  ', :green
      say path.gsub(/\A.\//, '')
      file
    end
  end
end
