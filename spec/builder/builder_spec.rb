require "spec_helper"

describe Antwort::Builder do
  before :each do
    @builder = Antwort::Builder.new
  end

  describe "Initialize" do
    it "has a template_name"
    it "has a build_id"
    it "has a markup_dir"
    it "has a source_dir"
    it "has a scss_dir"
    it "has an asset_server"
  end

  describe "Compiles" do
    it "SCSS"
    it "inline.scss"
    it "include.scss"
  end

  describe "Helpers" do
    it "creates files"
    it "creates IDs from Timestamps"
    it "changes relative assets URLs to use asset server"
    it "preserves `&nbsp;`s"
  end

end