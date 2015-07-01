require 'spec_helper'

describe Antwort::PartialBuilder do

  before :all do
    Dir.chdir(fixtures_root)
  end

  before :each do
    allow($stdout).to receive(:write) # Ignore warnings
    @builder = Antwort::PartialBuilder.new
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
          " &gt;= " => " >= ",
          " &lt;= " => " <= ",
          " &gt;= " => " >= ",
          " &amp;&amp; " => " && "
        }
        h.each do |key, value|
          expect(@builder.cleanup_logic(key)).to eq(value)
        end
      end
    end

    describe "Code and Logic" do
      it "does not confuse ends from ifs or loops"

      describe "Can preserve:" do

        it "comments" do
          h = {
            "<%# foo %>"  => "{# foo #}",
            "<% # foo %>" => "{# foo #}",
            "<% #foo %>"  => "{# foo #}",
            "<%#= foo %>" => "{#= foo #}",
            "<%# foo bar == cat %>" => "{# foo bar == cat #}"
          }
          h.each do |key, value|
            expect(@builder.preserve_comments(key)).to eq(value)
          end
        end

        it "conditionals" do
          # Regex requires matching closing end
          h = {
            '<% if foo %>do something<% end %>'           => '{% if foo %}do something{% endif %}',
            '<%if foo%>do something<%end%>'               => '{% if foo %}do something{% endif %}',
            '<% if foo=bar %>do something<% end %>'       => '{% if foo=bar %}do something{% endif %}',
            '<% if foo = \'bar\' %>do something<% end %>' => '{% if foo = \'bar\' %}do something{% endif %}',
            '<% if foo = "bar" %>do something<% end %>'   => '{% if foo = "bar" %}do something{% endif %}',
            '<% if foo %>bar<% else %>cat<% end %>'       => '{% if foo %}bar{% else %}cat{% endif %}',
            '<% if foo = bar %>bar<% elsif foo = cat %>cat<% else %>dog<% end %>' => '{% if foo = bar %}bar{% elseif foo = cat %}cat{% else %}dog{% endif %}'
          }
          h.each do |key, value|
            expect(@builder.preserve_conditionals(key)).to eq(value)
          end
        end

        it "loops" do
          h = {
            "<% cats.each do |cat| %>" => "{% for cat in cats %}",
            # "<% cats.each_with_index do |cat, i| %>" => "{% for cat in cats %}", # what about index?
            "<% end %>" => "{% endfor %}"
          }
          h.each do |key, value|
            expect(@builder.preserve_loops(key)).to eq(value)
          end
        end

        it "variables" do
          h = {
            "<%= cat %>" => "{{ cat }}",
            '#{foo}'     => "{{ foo }}",
            "foo[:bar]"          => "foo.bar",
            "foo[:bar][:cat]"    => "foo.bar.cat",
            "foo['bar']"         => "foo.bar",
            "foo['bar']['cat']"  => "foo.bar.cat",
            'foo["bar"]'         => "foo.bar",
            'foo["bar"]["cat"]'  => "foo.bar.cat"
          }
          h.each do |key, value|
            expect(@builder.preserve_variables(key)).to eq(value)
          end
        end

        it "variable assignments" do
          h = {
            "<% foo=bar %>" => "{% set foo = bar %}",
            "<% foo = bar %>" => "{% set foo = bar %}",
            "<% foo = 'bar' %>" => "{% set foo = 'bar' %}",
            "<% foo = [1, 2, 3] %>" => "{% set foo = [1, 2, 3] %}",
            "<% foo =  { key: val } %>" => "{% set foo = { key: val } %}",
            "<% foo ||= 'bar' %>" => "{% set foo = foo || 'bar' %}"
          }
          h.each do |key, value|
            expect(@builder.preserve_assignments(key)).to eq(value)
          end
        end
      end
    end
  end
end