require 'spec_helper'

class Dummy
end

describe Antwort::CLIHelpers do

  before :each do
    @helper = Dummy.new
    @helper.extend(Antwort::CLIHelpers)
  end

  describe 'CLI Helpers' do

    it '#built_emails' do
      b = @helper.built_emails
      expect(b).to include('demo-20160101')
      expect(b).to include('demo-20160102')
    end

    it '#available_emails - lists all available emails' do
      a = @helper.available_emails
      expect(a).to include('1-demo')
      expect(a).to include('2-no-layout')
      expect(a).to include('3-no-title')
    end

    it '#images_dir - returns images asset path by EMAIL_ID' do
      expect(@helper.images_dir('foo')).to eq './assets/images/foo'
    end

    it '#last_build_by_id' do
      expect(@helper.last_build_by_id 'foo').to eq('foo-1')
      expect(@helper.last_build_by_id 'demo').to eq('demo-20160102')
      expect(@helper.last_build_by_id 'demo').not_to eq('demo-20160101')
    end
  end
end