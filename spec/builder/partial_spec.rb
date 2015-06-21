require 'spec_helper'

describe Antwort::PartialBuilder do

  before :all do
    Dir.chdir(fixtures_root)
  end

  before :each do
    @builder = Antwort::PartialBuilder.new
  end

  describe "Builds" do
    it "builds HTML"
    it "inlines CSS"
  end

  describe "Helpers" do
    it "removes extra DOM from nokogiri"
    it "adjusts filename as necssary (make sure it ends with .html)"

    describe "Code and Logic" do
      it "preserves comments"
      it "preserves conditionals"
      it "preserves loops"
      it "preserves variables"
      it "does not confuse ends from ifs or loops"
      it "preserves variable assignments"
      it "cleans up logic mangled by html entities"
    end
  end

end