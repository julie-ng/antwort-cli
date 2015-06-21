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

  # describe '#confirms_upload?' do
  #   context 'option is true' do
  #     before :each do
  #       subject.options = { force: true }
  #     end

  #     it 'returns true' do
  #       expect(subject.confirms_upload?).to be_truthy
  #     end
  #   end

  #   context 'question got answered with yes' do
  #     before :each do
  #       subject.options = { force: false }
  #       expect(subject).to receive(:yes?).and_return(true)
  #     end

  #     it 'returns true' do
  #       expect(subject.confirms_upload?).to be_truthy
  #     end
  #   end

  #   context 'none is true' do
  #     before :each do
  #       subject.options = { force: false }
  #       expect(subject).to receive(:yes?).and_return(false)
  #     end

  #     it 'returns false' do
  #       expect(subject.confirms_upload?).to be_falsey
  #     end
  #   end
  # end

  # describe '#upload_mail' do
  #   before :each do
  #     subject.instance_variable_set(:@email_id, 'newsletter')
  #   end

  #   it 'creates new instance of Upload' do
  #     expect(Antwort::CLI::Upload).to receive(:new).with('newsletter') do
  #       double('Antwort::CLI::Upload').as_null_object
  #     end

  #     subject.upload_mail
  #   end

  #   it 'calls Upload#upload' do
  #     allow_any_instance_of(Antwort::CLI::Upload).to receive(:email_dir?) { true }
  #     expect_any_instance_of(Antwort::CLI::Upload).to receive(:upload)
  #     subject.upload_mail
  #   end
  # end
end
