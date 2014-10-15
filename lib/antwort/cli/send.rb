require 'mail'
require 'thor'

module Antwort
  class CLI
    class Send < Thor
      include Thor::Actions
      attr_reader :email_id, :to, :from, :subject

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

      def initialize(email_id, options={})
        @email_id     = email_id
        @to      = options[:recipient]
        @from    = options[:from]
        @subject = options[:subject]
      end

      no_commands do

        def send
          mail_from    = from
          mail_to      = to
          mail_subject = subject
          html_body    = File.open("build/#{@email_id}/build.html").read

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
            say "Sent #{email_id} at #{Time.now.strftime('%d.%m.%Y %H:%M')}", :green
          else
            say "Error sending #{email_id} at #{Time.now.strftime('%d.%m.%Y %H:%M')}", :red
          end

        end

      end
    end
  end
end