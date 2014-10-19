require 'fog'
require 'thor'

module Antwort
  class CLI
    class Upload < Thor
      include Thor::Actions
      include Antwort::CLIHelpers
      attr_reader :email_id

      def initialize(email_id, force = false)
        @force      = force
        @email_id   = email_id
        @images_dir = images_dir(email_id)
        check_credentials
      end

      no_commands do

        def check_credentials
          failed = false
          vars = ['ASSET_SERVER', 'AWS_BUCKET', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY']
          vars.each do |var|
            if ENV[var].nil?
              say "Error ", :red
              say "#{var} not set."
              failed = true
            end
          end

          if failed
            abort "Please fix your .env config file and try again."
          end
        end

        def upload
          count = count_files @images_dir
          abort "No images in #{@images_dir} to upload." if count === 0

          if confirm_upload(count)
            do_upload
          else
            say 'Upload aborted. ', :red
            say 'No files deleted or replaced.'
          end
        end

        def confirm_upload(count)
          yes?("Upload #{count} images and overwrite '#{email_id}' folder on assets server? (y/n)")
        end

        def do_upload
          clean_directory!
          Dir.foreach(@images_dir) do |f|
            next if f.to_s[0] == '.'
            directory.files.create(
              key: "#{email_id}/#{f}",
              body: File.open(File.join(@images_dir, f)),
              public: true
            )
            say '    create   ', :green
            say "#{ENV['ASSET_SERVER']}/#{email_id}/#{f}"
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
            connection.directories.get(ENV['AWS_BUCKET'], prefix: email_id)
        end

        def clean_directory!
          directory.files.each(&:destroy)
        end

      end
    end
  end
end
