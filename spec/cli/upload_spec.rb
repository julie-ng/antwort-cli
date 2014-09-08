require 'spec_helper'

describe Antwort::CLI::Upload do
  subject { described_class.new('newsletter') }
  before(:each) { Fog.mock! }
  after(:each) { Fog.unmock! }
  before(:each) do
    allow_any_instance_of(described_class).to receive(:email_dir?).and_return(true)
  end

  describe '#upload' do
    before :each do
      allow(Dir).to receive(:foreach)
    end

    it 'cleans S3 directory' do
      expect(subject).to receive(:clean_directory!)
      subject.upload
    end
  end

  describe '#connection' do
    it 'returns S3 connection' do
      expect(subject.connection).to be_a(Fog::Storage::AWS::Mock)
    end
  end

  describe '#directory' do
    it 'responds to #directory' do
      expect(subject).to respond_to(:directory)
    end
  end

  describe '#clean_directory!' do
    it 'responds to #clean_directory!' do
      expect(subject).to respond_to(:clean_directory!)
    end
  end
end
