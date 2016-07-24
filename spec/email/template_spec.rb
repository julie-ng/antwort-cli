require "spec_helper"

describe Antwort::EmailTemplate do

  before :all do
    @fixtures_path = "#{Dir.pwd}/spec/fixtures"
    @template = Antwort::EmailTemplate.new('1-demo', root: @fixtures_path)
  end

  describe "Initialization" do
    it "has a the name" do
      expect(@template.name).to eq('1-demo')
    end

    it "has a the path" do
      expect(@template.path).to eq("#{@fixtures_path}/emails/1-demo")
    end

    it "has a the index file" do
      expect(@template.file).to eq("#{@fixtures_path}/emails/1-demo/index.html.erb")
    end

    it "has a body" do
      result = <<~HEREDOC
        <h1>Hello World</h1>
        <p>This is email one.</p>
      HEREDOC
      expect(@template.body).to eq(result)
    end
  end

  describe "title attribute" do
    context "with a title" do
      it "returns the title" do
        expect(@template.title).to eq('Email One')
      end
    end

    context "without a title" do
      it "defaults to 'Untitled'" do
        expect(Antwort::EmailTemplate.new('3-no-title', root: @fixtures_path).title).to eq('Untitled')
      end
    end
  end

  describe "data attribute" do
    context "with a YAML file" do
      it "sets to YAML data" do
        expect(@template.data[:foo].length).to eq(2)
        expect(@template.data[:foo].first).to eq({title: 'foo'})
        expect(@template.data[:foo].last).to eq({title: 'bar'})
      end
    end

    context "without a YAML file" do
      it "defaults to empty hash" do
        expect(Antwort::EmailTemplate.new('3-no-title', root: @fixtures_path).data).to eq({})
      end
    end
  end

  describe "layout" do
    it "defaults to views/layout" do
      expect(Antwort::EmailTemplate.new('1-demo', root: @fixtures_path).layout).to eq('views/layout')
    end
    it "can be false (i.e. has no layout)" do
      expect(Antwort::EmailTemplate.new('2-no-layout', root: @fixtures_path).layout).to be false
    end
  end

  it "has a url helper" do
    expect(@template.url).to eq('/template/1-demo')
  end
end