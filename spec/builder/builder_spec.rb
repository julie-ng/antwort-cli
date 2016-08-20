require 'spec_helper'

describe Antwort::Builder do
  let(:build) { Antwort::Builder.new }

  describe 'Initialize' do
    it 'has a template_name'
    it 'has a build_id'
    it 'has a markup_dir'
    it 'has a source_dir'
    it 'has a scss_dir'
    it 'has an asset_server'
  end

  describe 'Compiles' do
    it 'SCSS'
    it 'inline.scss'
    it 'include.scss'
  end

  describe 'Helpers' do
    it 'changes relative assets URLs to use asset server'
    it 'preserves `&nbsp;`s'
  end
end
