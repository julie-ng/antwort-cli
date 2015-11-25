require 'spec_helper'

class Dummy
end

describe Antwort::LogicHelpers do

  before :each do
    @helper = Dummy.new
    @helper.extend(Antwort::LogicHelpers)
  end

  describe "non breaking spaces" do
    it "preserves by adjusting markup" do
      expect(@helper.preserve_nbsps('foo&nbsp;bar')).to eq('foo%nbspace%bar')
    end

    it "can restore to proper markup" do
      expect(@helper.restore_nbsps('foo%nbspace%bar')).to eq('foo&nbsp;bar')
    end
  end

  #-- Comments --

  describe "comments" do
    it "preserves erb comments" do
      h = {
        "<%# foo %>"  => "{# foo #}",
        "<% # foo %>" => "{# foo #}",
        "<% #foo %>"  => "{# foo #}",
        "<%#= foo %>" => "{#= foo #}",
        "<%# foo bar == cat %>" => "{# foo bar == cat #}"
      }
      h.each do |key, value|
        expect(@helper.preserve_comments(key)).to eq(value)
      end
    end

    it "preserves comments despite leading/trailing spaces" do
      expect(@helper.preserve_comments('<% # foo %>')).to eq('{# foo #}')
    end
  end

  #-- Variables --

  describe "variable outputs" do
    it "preserves interpolated strings" do
      expect(@helper.preserve_variables('<%= "color: #{foo};" %>')).to eq('{{ "color: #{foo};" }}')
    end

    context "hashes" do
      it "preserves nested" do
        expect(@helper.preserve_variables('<%= foo[:bar] %>')).to eq('{{ foo.bar }}')
        expect(@helper.preserve_variables('<%= foo[:bar][:cat] %>')).to eq('{{ foo.bar.cat }}')
      end

      it "preseves string keys" do
        expect(@helper.preserve_variables("<%= foo['bar'] %>")).to eq('{{ foo.bar }}')
        expect(@helper.preserve_variables("<%= foo['bar']['cat'] %>")).to eq('{{ foo.bar.cat }}')
        expect(@helper.preserve_variables('<%= foo["bar"] %>')).to eq('{{ foo.bar }}')
        expect(@helper.preserve_variables('<%= foo["bar"]["cat"] %>')).to eq('{{ foo.bar.cat }}')
      end
    end
  end

  #-- Assignments --

  describe "preserves assignments" do

    describe "incl. variables" do
      it "well-formatted code" do
        expect(@helper.preserve_assignments("<% foo = bar %>")).to eq("{% set foo = bar %}")
      end

      it "not well-formatted code" do
        expect(@helper.preserve_assignments("<% foo=bar %>")).to eq("{% set foo = bar %}")
        expect(@helper.preserve_assignments("<% foo =bar %>")).to eq("{% set foo = bar %}")
        expect(@helper.preserve_assignments("<% foo=bar %>")).to eq("{% set foo = bar %}")
      end
    end

    it "incl. strings" do
      expect(@helper.preserve_assignments('<% foo = "bar" %>')).to eq('{% set foo = "bar" %}')
      expect(@helper.preserve_assignments("<% foo = 'bar' %>")).to eq("{% set foo = 'bar' %}")
    end

    it "incl. integers" do
      expect(@helper.preserve_assignments('<% foo = 1 %>')).to eq('{% set foo = 1 %}')
      expect(@helper.preserve_assignments('<% foo=1 %>')).to eq('{% set foo = 1 %}')
    end

    it "incl. arrays" do
      h = {
        "<% foo = [1] %>" => "{% set foo = [1] %}",
        "<% foo = [ 1 ] %>" => "{% set foo = [ 1 ] %}",
        "<% foo = [1,2] %>" => "{% set foo = [1,2] %}",
        "<% foo = [1, 2, 3] %>" => "{% set foo = [1, 2, 3] %}"
      }
      h.each do |key, value|
        expect(@helper.preserve_assignments(key)).to eq(value)
      end
    end

    it "incl. objects/hashes" do
      expect(@helper.preserve_assignments('<% foo =  { key: val } %>')).to eq('{% set foo = { key: val } %}')
    end

    it "respects memoized assignemnts" do
      expect(@helper.preserve_assignments('<% foo ||= "bar" %>')).to eq('{% set foo = foo || "bar" %}')
    end
  end

  #-- Conditionals --

  describe "conditionals" do
    describe "if" do
      it "/ end" do
        h = {
          '<% if foo %>do something<% end %>'           => '{% if foo %}do something{% end %}',
          '<%if foo%>do something<%end%>'               => '{% if foo %}do something{% end %}',
          '<% if foo=bar %>do something<% end %>'       => '{% if foo=bar %}do something{% end %}',
          '<% if foo = \'bar\' %>do something<% end %>' => '{% if foo = \'bar\' %}do something{% end %}',
          '<% if foo = "bar" %>do something<% end %>'   => '{% if foo = "bar" %}do something{% end %}',
          '<% if i < @config.products.length - 1 %>'    => '{% if i < @config.products.length - 1 %}',
          '<% if i<@config.products.length-1 %>'    => '{% if i<@config.products.length-1 %}'
        }
        h.each do |key, value|
          expect(@helper.preserve_conditionals(key)).to eq(value)
        end
      end

      it "/ else / end" do
        expect(@helper.preserve_conditionals('<% if foo %>bar<% else %>cat<% end %>')).to eq('{% if foo %}bar{% else %}cat{% end %}')
      end

      it "/ elsif / else / end" do
        expect(@helper.preserve_conditionals('<% if foo = bar %>bar<% elsif foo = cat %>cat<% else %>dog<% end %>')).to eq('{% if foo = bar %}bar{% elseif foo = cat %}cat{% else %}dog{% end %}')
      end
    end

    describe "unless" do
      it "/ end"
      it "/ else / end"
    end
  end

  #-- Loops --

  describe "loops" do
    it "preserves each loops as for loops" do
      h = {
        "<% cats.each do |cat| %>" => "{% for cat in cats %}",
        "<% cats.each do | cat | %>" => "{% for cat in cats %}",
        "<% cats.each_with_index do | cat , i | %>" => "{% for cat in cats %}", # what about index?
        "<% cats.each_with_index do |cat, i| %>" => "{% for cat in cats %}", # what about index?
        "<% end %>" => "{% end %}"
      }
      h.each do |key, value|
        expect(@helper.preserve_loops(key)).to eq(value)
      end
    end

    it "preserves each_with_index"
  end

end
