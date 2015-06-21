require 'spec_helper'

describe Antwort::CLI do

  before :all do
    Dir.chdir(fixtures_root)
  end

  describe '#upload' do
    let(:output) { capture(:stdout) { subject.upload('newsletter') } }

    before :each do
      allow($stdout).to receive(:write)
    end

    context 'user confirms upload' do
      before :each do
        allow_any_instance_of(Thor::Actions).to receive(:yes?).and_return(true)
      end

      it 'uploads mail' do
        expect(subject).to receive(:upload)
        output
      end

      it 'messages success' do
        expect(output).to include('create')
      end
    end

    context 'user denies upload' do
      before :each do
        allow_any_instance_of(Thor::Actions).to receive(:yes?).and_return(false)
      end

      it 'does not upload mail' do
        expect(subject).not_to receive(:upload_mail)
        output
      end

      it 'messages cancelation' do
        expect(output).to include('aborted')
      end
    end
  end
end
