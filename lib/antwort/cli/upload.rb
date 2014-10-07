require 'fog'
require 'dotenv'
require 'thor'

module Antwort
  class CLI
    class Upload < Thor
      include Thor::Actions
      attr_reader :email_id

      def initialize(email_id)
        Dotenv.load
        @email_id = email_id
        fail ArgumentError, "Email #{email_id} does not exists" unless email_dir?
      end

      no_commands do

        def upload
          clean_directory!

          Dir.foreach(assets_dir) do |f|
            next if f.to_s[0] == '.'

            directory.files.create(
              key: "#{email_id}/#{f}",
              body: File.open(File.join(assets_dir, f)),
              public: true
            )

            # puts "  ceated #{ENV['ASSET_SERVER']}/#{email_id}/#{f}"
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

        def assets_dir
          @assets_dir ||= File.join('.', 'assets', 'images', email_id)
        end

        def email_dir
          @email_dir ||= File.join('.', 'emails', email_id)
        end

        def email_dir?
          Dir.exist?(email_dir)
        end
      end
    end
  end
end
