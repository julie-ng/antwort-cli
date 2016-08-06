require 'spec_helper'

class Dummy
end

describe Antwort::CLIHelpers do

  before :each do
    @helper = Dummy.new
    @helper.extend(Antwort::CLIHelpers)
  end

  before :all do
    Dir.chdir(fixtures_root)
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

    it '#count_files' do
      expect(@helper.count_files './assets/images/shared').to be(2)
      expect(@helper.count_files './assets/images/1-demo').to be(1)
    end

    it '#last_build_by_id' do
      expect(@helper.last_build_by_id 'foo').to eq('foo-1')
      expect(@helper.last_build_by_id 'demo').to eq('demo-20160102')
      expect(@helper.last_build_by_id 'demo').not_to eq('demo-20160101')
    end

    it '#list_folders' do
      a = @helper.list_folders '.'
      expect(a).to include('assets')
      expect(a).to include('build')
      expect(a).to include('data')
      expect(a).to include('emails')
      expect(a).to include('views')
      expect(a).not_to include('support')
      expect(a).not_to include('lib')
    end

  end
end