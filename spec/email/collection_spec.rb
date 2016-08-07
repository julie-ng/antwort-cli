require 'spec_helper'

describe Antwort::EmailCollection do

  let(:collection) { Antwort::EmailCollection.new }
  let(:fixtures_email_list) { ['1-demo', '2-no-layout', '3-no-title', '4-custom-layout', 'demo', 'no-images'] }

  before :each do
    allow($stdout).to receive(:write)
  end

  describe "has a templates attribute" do
    it "is an array" do
      expect(collection.templates).to be_kind_of(Array)
    end

    it "holds EmailTemplates" do
      expect(collection.templates.first).to be_kind_of(Antwort::EmailTemplate)
    end

    it "loads emails by directory names" do
      result = fixtures_email_list
      expect(collection.list).to eq(result)
    end

    describe "filters" do
      it "excludes non-email folders" do
        expect(collection.list).not_to include('.')
        expect(collection.list).not_to include('..')
      end

      it "excludes the shared folder" do
        expect(collection.list).not_to include('shared')
      end
    end

    describe "API" do
      describe "`#empty?`" do
        context "has templates" do
          it "returns false" do
            expect(collection.empty?).to be false
          end
        end
        context "has no templates" do
          it "returns true" do
            Dir.chdir("#{fixtures_root}/emails")
            c = Antwort::EmailCollection.new
            expect(c.empty?).to be true

            # Go back or randomized specs fail
            Dir.chdir(fixtures_root)
          end
        end
      end

      it "#total" do
        expect(collection.total).to eq fixtures_email_list.length
      end
    end

  end
end