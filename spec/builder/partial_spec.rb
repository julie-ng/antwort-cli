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
    it "adjusts filename as necssary (make sure it ends with .html)" do
      expect(@builder.adjust_filename('foo.html.erb')).to eq('foo.html')
      expect(@builder.adjust_filename('_foo.html.erb')).to eq('_foo.html')
      expect(@builder.adjust_filename('foo.erb')).to eq('foo.html')
      expect(@builder.adjust_filename('_foo.erb')).to eq('_foo.html')
      expect(@builder.adjust_filename('_foo.html')).to eq('_foo.html')
    end

    describe "save from Nokogiri" do
      let (:start) { '<div id="valid-dom-tree">' }
      let (:ende)  {'</div><!--/#valid-dom-tree-->' }

      it "can add nokogiri wrapper" do
        expect(@builder.send(:add_nokogiri_wrapper, 'foo')).to eq(start + 'foo' + ende)
      end

      it "can remove nokogiri wrapper" do
        expect(@builder.send(:remove_nokogiri_wrapper, start + 'foo' + ende)).to eq('foo')
        expect(@builder.send(:remove_nokogiri_wrapper, start + 'foo' + "</div>  <!--/#valid-dom-tree-->")).to eq('foo')
        expect(@builder.send(:remove_nokogiri_wrapper, start + 'foo' + "</div>\n<!--/#valid-dom-tree-->")).to eq('foo')
      end

      it "adds wrapper before inlining"
      it "removes wrapper after inlining"
    end

    describe "Clean up" do
      it "can convert logic html entities back to operators" do
        h = {
          "{% &lt;= %}" => "{% <= %}",  # only convert operators within logic
          "{{ &lt;= }}" => "{{ <= }}",  # leave operators in content
          "{% &gt;= %}" => "{% >= %}",
          "{{ &gt;= }}" => "{{ >= }}",
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