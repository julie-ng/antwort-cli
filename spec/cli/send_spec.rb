require 'spec_helper'

describe Antwort::CLI::Send do

  before :all do
    Dir.chdir(fixtures_root)
  end

  after :each do
    Mail::TestMailer.deliveries.clear
  end

  describe 'Send' do
    it 'can send emails' do
      Antwort::CLI::Send.new('demo-20160101').send
      expect(Mail::TestMailer.deliveries.length).to eq(1)
    end
  end

  describe 'Defaults' do
    before :each do
      @a = Antwort::CLI::Send.new('demo-20160101')
      @a.send
      @sent = Mail::TestMailer.deliveries.last
    end

    it 'has a default text body' do
      expect(@sent.text_part.body).to eq('This is plain text')
    end

    describe 'set by environment variables' do
      it 'from' do
        expect(@sent.from.length).to eq(1)
        expect(@sent.from.first).to eq('TEST_ENV_SEND_FROM')
      end

      it 'to' do
        expect(@sent.to.length).to eq(1)
        expect(@sent.to.first).to eq('TEST_ENV_SEND_TO')
      end
    end

    it "uses to build <title> prefixed with '[Test] '" do
      expect(@sent.subject).to eq('[Test] Fixture Demo')
    end

    it 'has an HTML body, that is pulled from build index.html' do
      # comes back as empty string in testing?
      # expect(@sent.html_part.body.to_s).not_to eq ''
      # puts @sent.to_s.inspect

      contents = File.open("build/demo-20160101/demo.html").read
      expect(@a.html_body).to eq(contents)
    end
  end

  describe 'Optional Arguments' do
    before :each do
      Antwort::CLI::Send.new('demo-20160101', {
        from: 'CUSTOM_FROM',
        recipient: 'CUSTOM_TO',
        subject: 'MY SUBJECT'
      }).send
      @sent = Mail::TestMailer.deliveries.last
    end

    it 'accepts a sender argument' do
      expect(@sent.from.first).to eq('CUSTOM_FROM')
    end

    it 'accepts one recipient' do
      expect(@sent.to).to include('CUSTOM_TO')
    end

    it 'accepts multiple recipients' do
      Antwort::CLI::Send.new('demo-20160101', recipient: 'one, two').send
      expect(Mail::TestMailer.deliveries.last.to).to eq(['one', 'two'])
    end

    it 'accepts a title argument' do
      expect(@sent.subject).to eq('MY SUBJECT')
    end
  end
end