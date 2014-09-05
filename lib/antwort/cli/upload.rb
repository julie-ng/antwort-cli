module Antwort
  class CLI
    class Upload
      attr_reader :email_id

      def initialize(email_id)
        @email_id = email_id
      end

      def upload
      end

      def connection
        @connection ||=
          Fog::Storage.new(
            provider: 'AWS',
            aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
            aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
          )
      end

      def directory
        @directory ||=
          connection.directories.create(
            key: "#{ENV['ASSET_DIRECTORY']}/"
          )
      end
    end
  end
end
