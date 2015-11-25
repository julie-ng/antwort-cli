require 'spec_helper'

describe Antwort::PartialBuilder do

  before :all do
    Dir.chdir(fixtures_root)
  end

  before :each do
    allow($stdout).to receive(:write) # Ignore warnings
    @builder = Antwort::PartialBuilder.new({id: 'foo', 'css-style': 'expanded'})
  end

  describe "Builds" do
    it "builds HTML"
    it "inlines CSS"
  end

  describe "Helpers" do
    it "removes extra DOM from nokogiri"
    it "adjusts filename as necssary (make sure it ends with .html)"

    describe "Clean up" do
      it "# can clean up logic mangled by html entities" do
        # and preserves spaces
        h = {
          " &lt;= " => " <= ",
          " &gt;= " => " >= ",
          " &amp;&amp; " => " && "
        }
        h.each do |key, value|
          expect(@builder.cleanup_logic(key)).to eq(value)
        end
      end

      it "can restore variables in links" do
        a = '<a href="%7B%7B%20hello%20%7D%7D">world</a>'
        b = '<a href="{{ hello }}">world</a>'
        expect(@builder.restore_variables_in_links(a)).to eq(b)
      end
    end
  end
end