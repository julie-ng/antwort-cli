require "spec_helper"

describe Antwort::EmailData do
  before :all do
    #@fixtures_root = fixtures_root# "#{Dir.pwd}/spec/fixtures/"
    @data = Antwort::EmailData.new(name: '1-demo', path: fixtures_root)
  end

  describe "on Initialization" do
    it "has a name attribute" do
      expect(@data.name).to eq('1-demo')
    end

    describe "has a path attribute, which" do
      it "has /data appended" do
        expect(@data.path).to eq(fixtures_root + '/data')
      end

      it "defaults to pwd/data" do
        expect(Antwort::EmailData.new(name: 'foo').path).to eq("#{Dir.pwd}/data")
      end
    end

    describe "has a file, which" do
      it "can be set as param" do
        a = Antwort::EmailData.new({file: '/usr/foo/bar.yml'})
        expect(a.file).to eq('/usr/foo/bar.yml')
      end

      it "defaults to pwd/data" do
        a = Antwort::EmailData.new(name: '1-demo')
        expect(a.file).to eq("#{Dir.pwd}/data/1-demo.yml")
      end
    end

    it "has a data attribute" do
      result = {
        foo: [{title: 'foo'}, {title: 'bar'}]
      }
      expect(@data.data).to eq(result)
    end
  end

end