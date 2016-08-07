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

    def last_build_by_id(email_id)
      built_emails.select { |f| f.split('-')[0..-2].join('-') == email_id }.sort.last
    end

    def list_partials(folder_name)
      path = File.expand_path(folder_name)
      Dir.entries(path).select { |f| f[0]== '_' && f[-4,4] == '.erb' }
    end

  end
end
