require 'fileutils'
require 'thor'

module Antwort
  module CLIHelpers

    def built_emails
      list_folders('./build')
    end

    def available_emails
      list_folders('./emails')
    end

    def images_dir(email_id)
      "./assets/images/#{email_id}"
    end

    def count_files(dir)
      Dir[File.join(dir, '**', '*')].count { |f| File.file? f }
    end

    def last_build_by_id(email_id)
      built_emails.select { |f| f.include? email_id }.sort.last
    end

    def list_folders(folder_name)
      path = File.expand_path(folder_name)
      Dir.entries(path).select { |f| !f.include? '.' }
    end

    def folder_exists?(folder_name)
      if Dir.exists?(folder_name)
        return true
      else
        say "Error: Folder #{folder_name} does not exist.", :red
        return false
      end
    end

  end
end
