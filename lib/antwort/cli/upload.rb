require 'fog'

module Antwort
  class CLI
    class Upload < Thor
      include Thor::Actions
      include Antwort::FileHelpers

      attr_reader :email_id, :template

      def initialize(email_id)
        @email_id = email_id
        @template = Antwort::EmailTemplate.new(email_id)

        check_credentials
      end

      no_commands do
        def check_credentials
          failed = false
          vars = %w(ASSET_SERVER AWS_BUCKET AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY)
          vars.each do |var|
            next unless ENV[var].nil?
            say 'Error ', :red
            say "#{var} not set."
            failed = true
          end

          abort 'Please fix your .env config file and try again.' if failed
        end

        def upload
          unless @template.has_images?
            abort "#{@template.name} has no images to upload."
          end

          if confirms_upload?
            do_upload
          else
            say 'Upload aborted. ', :red
            say 'No files deleted or replaced.'
          end
        end

        def confirms_upload?
          yes?("Upload #{@template.images.length} images and overwrite '#{@template.name}' folder on assets server? (y/n)")
        end

        def do_upload
          clean_directory!

          @template.images.each do |f|
            directory.files.create(
              key: upload_path(f),
              body: File.open(@template.image_path(f)),
              public: true
            )
            say '    create   ', :green
            say "#{ENV['ASSET_SERVER']}/#{upload_path(f)}"
          end
        end

        def connection
          @connection ||=
            Fog::Storage.new(
              provider: 'AWS',
              aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
              aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
              region: ENV['FOG_REGION']
            )
        end

        def directory
          return @directory if defined?(@directory)

          @directory ||=
            connection.directories.get(ENV['AWS_BUCKET'], prefix: @template.name)
        end

        def upload_path(file)
          "#{@template.name}/#{file}"
        end

        def clean_directory!
          directory.files.each(&:destroy)
        end
      end
    end
  end
end
