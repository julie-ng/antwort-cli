require 'spec_helper'

describe Antwort::CLI::Upload do

  subject { Antwort::CLI::Upload.new('1-demo') }

  before :each do
    Fog.mock!
    allow_any_instance_of(Thor::Actions).to receive(:yes?).and_return(true)
  end

  after(:each) {  Fog.unmock! }

  describe '#upload' do
    before :each do
      allow(Dir).to receive(:foreach)
    end

    xit 'cleans S3 directory before upload' do
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

  describe('#upload_path') do
    it 'retuns AWS path (excludes assets/images)' do
      expect(subject.upload_path 'foo.png').to eq('1-demo/foo.png')
    end
  end

  it 'uploads files to AWS'
  it 'allows user to abort upload'
end
