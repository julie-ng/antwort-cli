require 'thor/shell'
require 'mail'

module Antwort
  class CLI
    class Send
      include Thor::Shell
      attr_reader :build_id, :sender, :recipient, :subject, :html_body, :mail

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
        @build_id  = build_id
        @html_body = File.open("build/#{build_id}/#{template_name}.html").read

        @recipient = (options[:recipient] || ENV['SEND_TO']).split(',')
        @sender    = options[:from] || ENV['SEND_FROM']
        @subject   = options[:subject] || "[Test] " << extract_title(@html_body)
      end

      def send
        # because scope changes inside mail DSL
        mail_from    = @sender
        mail_to      = @recipient
        mail_subject = @subject

        # setup email
        @mail = Mail.new do
          from     mail_from
          to       mail_to
          subject  mail_subject

          text_part do
            body 'This is plain text'
          end

          html_part do
            content_type 'text/html'
            body @html_body
          end
        end

        # send email
        if @mail.deliver!
          say "Sent Email \"#{template_name}\" at #{Time.now.strftime('%d.%m.%Y %H:%M')}", :green
          say "  to:      #{@recipient}"
          say "  subject: #{@subject}"
          say "  html:    #{build_id}/#{template_name}.html"
        else
          say "Error sending #{build_id}/#{template_name} at #{Time.now.strftime('%d.%m.%Y %H:%M')}", :red
        end
      end

      private

      def template_name
        @build_id.split('-')[0...-1].join('-') # removes timestamp ID
      end

      def extract_title(body = '')
        body.scan(%r{<title>(.*?)</title>}).first.first
      end

    end
  end
end