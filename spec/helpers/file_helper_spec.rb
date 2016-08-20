require 'spec_helper'

class Dummy
end

describe Antwort::FileHelpers do
  let(:helper) { Dummy.new.extend(Antwort::FileHelpers) }

  it '#count_files' do
    expect(helper.count_files('./assets/images/shared')).to be(2)
    expect(helper.count_files('./assets/images/1-demo')).to be(1)
  end

  it '#list_folders' do
    a = helper.list_folders '.'
    expect(a).to include('assets')
    expect(a).to include('build')
    expect(a).to include('data')
    expect(a).to include('emails')
    expect(a).not_to include('support')
    expect(a).not_to include('lib')
  end

  it '#email_id_from_folder_name' do
    expect(helper.email_id_from_folder_name('foo-123')).to eq('foo')
    expect(helper.email_id_from_folder_name('foo-bar-123')).to eq('foo-bar')
    expect(helper.email_id_from_folder_name('foo_bar-123')).to eq('foo_bar')
    expect(helper.email_id_from_folder_name('past-event-notification-20160330173522')).to eq('past-event-notification')
  end
end
