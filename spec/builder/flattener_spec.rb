require "spec_helper"

describe Antwort::Flattener do

  describe "initialize" do
    it "saves source to a attr_reader" do
      s = Antwort::Flattener.new('<td>')
      expect(s.source).to eq('<td>')
    end

    describe "saves matches to an array" do
      it "matches single style per source" do
        s = Antwort::Flattener.new('<div style="color:black">')
        expect(s.styles).to eq(['color:black'])
      end
      it "matches multiple styles per source" do
        s = Antwort::Flattener.new('<td style="background-color:#cccccc"><div style="color: red">')
        expect(s.styles).to eq(["background-color:#cccccc", "color: red"])
      end
    end
  end

  describe "flattens css styles" do
    it "a single match" do
      s = Antwort::Flattener.new('<div style="color:black;color:red;background:white;">').flatten
      expect(s.flattened_styles).to eq(['color:red;background:white'])
      expect(s.flattened).to eq('<div style="color:red;background:white">')
    end

    describe "multiple styles" do
      before :all do
        @s = Antwort::Flattener.new('<td style="color:black;color:red;"><div style="background:white;">')
        @s.flatten
      end

      it "produces flattened styles as an array" do
        expect(@s.flattened_styles).to eq(['color:red','background:white'])
      end

      it "stores original source as a string" do
        expect(@s.source).to eq('<td style="color:black;color:red;"><div style="background:white;">')
      end

      it "stores flattened source as a string" do
        expect(@s.flattened).to eq('<td style="color:red"><div style="background:white">')
      end
    end
  end

  describe "code cleanup" do
    before :all do
      @s = Antwort::Flattener.new('<td style="color: black;">').flatten
    end

    it "removes trailing semicolon;" do
      expect(@s.flattened).not_to eq('<td style="color:black;">')
    end
    it "remove extra white space" do
      expect(@s.flattened).not_to eq('<td style="color: black">')
    end
  end

  describe "private helpers" do
    before :all do
      @s = Antwort::Flattener.new
    end

    it "flattens styles strings" do
      expect(@s.send(:flatten_str, 'color:red;color:black;font-size:12px')).to eq('color:black;font-size:12px')
    end

    it "can split styles string into a hash, flattening duplicate attributes" do
      expect(@s.send(:str_to_hash, 'color:red;color:black;border:none;font-size:12px')).to eq({
        'color' => 'black',
        'border' => 'none',
        'font-size' => '12px'})
    end

    it "trims leading and trailing white space form hash keys and values" do
      expect(@s.send(:str_to_hash, 'color:red; color: black;border :none;')).to eq({
        'color' => 'black',
        'border' => 'none'})
    end

    it "can push styles hash back into sting" do
      hash = { 'font-size' => '14px', 'font-family' => 'Helvetica' }
      expect(@s.send(:hash_to_str, hash)).to eq('font-size:14px;font-family:Helvetica')
    end
  end
end