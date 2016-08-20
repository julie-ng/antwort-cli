require 'spec_helper'

describe Antwort::Flattener do
  describe 'initialize' do
    it 'saves source to a attr_reader' do
      s = Antwort::Flattener.new('<td>')
      expect(s.source).to eq('<td>')
    end

    describe 'saves matches to an array' do
      it 'matches single style per source' do
        s = Antwort::Flattener.new('<div style="color:black">')
        expect(s.styles).to eq(['color:black'])
      end
      it 'matches multiple styles per source' do
        s = Antwort::Flattener.new('<td style="background-color:#cccccc"><div style="color: red">')
        expect(s.styles).to eq(['background-color:#cccccc', 'color: red'])
      end
    end
  end

  describe 'flattens css styles' do
    it 'a single match' do
      s = Antwort::Flattener.new('<div style="color:black;color:red;background:white;">').flatten
      expect(s.flattened).to eq('<div style="color:red;background:white">')
    end

    describe 'multiple styles' do
      let(:style) { Antwort::Flattener.new('<td style="color:black;color:red;"><div style="background:white;">').flatten }

      it 'stores original source as a string' do
        expect(style.source).to eq('<td style="color:black;color:red;"><div style="background:white;">')
      end

      it 'stores flattened source as a string' do
        expect(style.flattened).to eq('<td style="color:red"><div style="background:white">')
      end
    end

    describe 'method flattened?' do
      it 'returns true if changes where made' do
        s = Antwort::Flattener.new('<td style="color: red; color: black;">').flatten
        expect(s.flattened?).to eq(true)
      end
      it 'returns false if chnages were not made' do
        s = Antwort::Flattener.new('<td style"color:red">').flatten
        expect(s.flattened?).to eq(false)
      end
    end
  end

  describe 'code cleanup' do
    let(:style) { Antwort::Flattener.new('<td style="color: black;">').flatten }

    it 'removes trailing semicolon;' do
      expect(style.flattened).to eq('<td style="color:black">')
      expect(style.flattened).not_to eq('<td style="color:black;">')
    end
    it 'remove extra white space' do
      expect(style.flattened).not_to eq('<td style="color: black">')
    end
  end
end
