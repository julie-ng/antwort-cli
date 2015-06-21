require "spec_helper"

describe Antwort::EmailBuilder do
  before :each do
    @builder = Antwort::EmailBuilder.new
  end

  describe "Builds" do
    it "builds HTML"
    it "inlines CSS"
  end

  describe "Helpers" do
    it "can inline CSS"
    it "cleans up markup"
    it "removes livereload"
    it "adds in the responsive/included CSS"
    it "removes excessive newlines"
  end

end