require 'mail'

module Antwort
  class CLI
    class Send < Thor
      include Thor::Actions
      attr_reader :build_id, :to, :from, :subject

      Mail.defaults do
        delivery_method :smtp,
                        address:   ENV['SMTP_SERVER'],
                        port:      ENV['SMTP_PORT'],
                        user_name: ENV['SMTP_USERNAME'],
                        password:  ENV['SMTP_PASSWORD'],
                        authentication: 'plain',
                        enable_starttls_auto: false,
                        return_response: true
      end

      def initialize(build_id, options={})
        @build_id = build_id
        @to       = options[:recipient]
        @from     = options[:from]
        @subject  = options[:subject]
      end

      no_commands do

        def template_name
          @build_id.split('-')[0...-1].join('-') # removes timestamp ID
        end

        def build_folder
          "build/#{@build_id}"
        end

        def send
          mail_from    = from
          mail_to      = to
          mail_subject = subject
          html_body    = File.open("#{build_folder}/#{template_name}.html").read

          mail = Mail.new do
            from    mail_from
            to      mail_to
            subject mail_subject

            text_part do
              body 'This is plain text'
            end

            html_part do
              content_type 'text/html; charset=UTF-8'
              body html_body
            end
          end

          if mail.deliver!
            puts mail.inspect
            say "Sent #{build_id} at #{Time.now.strftime('%d.%m.%Y %H:%M')}", :green
          else
            say "Error sending #{build_id} at #{Time.now.strftime('%d.%m.%Y %H:%M')}", :red
          end

        end
      end
    end
  end
end