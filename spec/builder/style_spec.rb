require 'spec_helper'

describe Antwort::Style do
  describe 'on Initialize' do
    let(:style) { Antwort::Style.new('font-weight:bold;font-size:24px;line-height:28px;font-family:Helvetica, Arial, sans-serif;color:#111111;color:#2CA4D8') }

    it 'remembers all keys' do
      expect(style.keys).to eq(['font-weight', 'font-size', 'line-height', 'font-family', 'color'])
    end
    it 'remembers duplicate keys' do
      expect(style.duplicate_keys).to eq(['color'])
    end
  end

  describe 'Readable Attributes' do
    let(:style) { Antwort::Style.new('font-size:24px;color:black;color:red') }

    context 'not flattened' do
      it 'can be accessed as a hash' do
        expect(style.original).to eq([{ 'font-size' => '24px' }, { 'color' => 'black' }, { 'color' => 'red' }])
      end
      it 'can be accessed as a string' do
        expect(style.original_str).to eq('font-size:24px;color:black;color:red')
      end
    end

    context 'flattened' do
      it 'can be accessed as a hash' do
        expect(style.flattened).to eq('font-size' => '24px', 'color' => 'red')
      end
      it 'can be accessed as a string' do
        expect(style.flattened_str).to eq('font-size:24px;color:red')
      end
    end

    it 'has a duplicates? method' do
      expect(Antwort::Style.new('color:red;color:black').duplicates?).to eq(true)
      expect(Antwort::Style.new('color:red;font-size:12px').duplicates?).to eq(false)
    end
  end

  describe 'Code Formatting' do
    it 'trims leading and trailing white space from styles' do
      style = Antwort::Style.new('color:red; color: black;border :none;')
      expect(style.flattened).to eq('color' => 'black', 'border' => 'none')
      expect(style.flattened).not_to eq(' color' => ' black', 'border ' => 'none')
    end
  end

  describe 'Internal Helpers' do
    it 'can push styles hash back into sting' do
      hash = { 'font-size' => '14px', 'font-family' => 'Helvetica' }
      style = Antwort::Style.new
      expect(style.send(:hash_to_str, hash)).to eq('font-size:14px;font-family:Helvetica')
    end
  end
end
