require "spec_helper"

describe Antwort::EmailCollection do
  before :all do
    @fixtures = "#{Dir.pwd}/spec/fixtures/emails"
    @c = Antwort::EmailCollection.new(source: @fixtures)
  end

  it "has a source attribute" do
    expect(@c.source).to eq(@fixtures)
  end

  describe "has a templates attribute" do
    it "is an array" do
      expect(@c.templates).to be_kind_of(Array)
    end

    it "holds EmailTemplates" do
      expect(@c.templates.first).to be_kind_of(Antwort::EmailTemplate)
    end

    it "loads emails by directory names" do
      result = ['1-demo', '2-no-layout', '3-no-title']
      expect(@c.list).to eq(result)
    end

    describe "filters" do
      it "excludes non-email folders" do
        expect(@c.list).not_to include('.')
        expect(@c.list).not_to include('..')
      end

      it "excludes the shared folder" do
        expect(@c.list).not_to include('shared')
      end
    end
  end
end