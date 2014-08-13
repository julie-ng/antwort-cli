require 'mail'

desc 'Sends email via SMTP by id={hash_id} (optional: subject={subject_line})'
task :send do
  id = ENV['id']
  subject = ENV['subject'] || 'Email Test'

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
    to       ENV['email'] || ENV['SMTP_EMAIL']
    subject  subject

    text_part do
      body 'This is plain text'
    end

    html_part do
      content_type 'text/html; charset=UTF-8'
      body File.open("tmp/newsletter-#{id}/output.html").read
    end
  end

  puts "Response #{Time.now.strftime("%d.%m.%Y %H:%M")}:"
  puts mail.inspect
end