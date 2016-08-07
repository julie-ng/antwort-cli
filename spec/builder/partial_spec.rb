require 'spec_helper'

describe Antwort::PartialBuilder do

  let(:builder) { Antwort::PartialBuilder.new({email: '1-demo', id: '123', 'css-style': 'expanded'}) }

  describe "Builds" do
    it "builds HTML"
    it "inlines CSS"
  end

  describe "Helpers" do
    describe "adjusts filename as necssary (make sure it ends with .html)" do

      it "always starts with _" do
        expect(builder.adjust_filename('foo.erb')).to eq('_foo.html')
        expect(builder.adjust_filename('foo.html')).to eq('_foo.html')
        expect(builder.adjust_filename('foo.html.erb')).to eq('_foo.html')
      end

      it "always ends with .html" do
        expect(builder.adjust_filename('_foo.html.erb')).to eq('_foo.html')
        expect(builder.adjust_filename('_foo.erb')).to eq('_foo.html')
        expect(builder.adjust_filename('_foo.html')).to eq('_foo.html')
      end

      it "uses template name instead of _index" do
        expect(builder.adjust_filename('index.html.erb')).to eq('_1-demo.html')
      end
    end

    describe "save from Nokogiri" do
      let (:start) { '<div id="valid-dom-tree">' }
      let (:ende)  {'</div><!--/#valid-dom-tree-->' }

      it "can add nokogiri wrapper" do
        expect(builder.send(:add_nokogiri_wrapper, 'foo')).to eq(start + 'foo' + ende)
      end

      it "can remove nokogiri wrapper" do
        expect(builder.send(:remove_nokogiri_wrapper, start + 'foo' + ende)).to eq('foo')
        expect(builder.send(:remove_nokogiri_wrapper, start + 'foo' + "</div>  <!--/#valid-dom-tree-->")).to eq('foo')
        expect(builder.send(:remove_nokogiri_wrapper, start + 'foo' + "</div>\n<!--/#valid-dom-tree-->")).to eq('foo')
      end

      # TODO: These specs don't work because PartialBuilder cannot find matching CSS

      it "adds wrapper before inlining", skip: true do
        builder.inline('foo')
        expect(builder).to receive(:add_nokogiri_wrapper)
      end

      it "removes wrapper after inlining", skip: true do
        builder.inline('foo')
        expect(builder).to receive(:remove_nokogiri_wrapper)
      end
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
          expect(builder.cleanup_logic(key)).to eq(value)
        end
      end

      it "can restore variables in links" do
        a = '<a href="%7B%7B%20hello%20%7D%7D">world</a>'
        b = '<a href="{{ hello }}">world</a>'
        expect(builder.restore_variables_in_links(a)).to eq(b)
      end
    end
  end
end