require 'mail'
require 'dotenv'
Dotenv.load

desc 'Sends email via SMTP by id={template_name} email={recipient} (optional: subject={subject_line})'
task :send do
  id                = ENV['id'] || Dir.entries(File.expand_path('./build')).last
  default_recipient = ENV['SMTP_EMAIL']
  recipient         = ENV['email'].nil? ? default_recipient : ENV['email']
  subject           = ENV['subject'] || 'Email Test'

  puts "Sending #{id} to #{recipient} ..."

  Mail.defaults do
    delivery_method :smtp, {
      :address => ENV['SMTP_SERVER'],
      :port => '25',
      :user_name => ENV['SMTP_USERNAME'],
      :password => ENV['SMTP_PASSWORD'],
      :authentication => 'plain',
      :enable_starttls_auto => false,
      :return_response => true
    }
  end

  mail = Mail.deliver do
    from     ENV['SMTP_USERNAME']
    to       recipient
    subject  subject

    text_part do
      body 'This is plain text'
    end

    html_part do
      content_type 'text/html; charset=UTF-8'
      body File.open("build/#{id}/build.html").read
    end
  end

  puts "Sent #{Time.now.strftime("%d.%m.%Y %H:%M")}:"
  puts mail.inspect
end