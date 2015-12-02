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

  describe "statements" do
    it "preserves erb markup" do
      expect(@helper.preserve_erb_code('<% user.merge!({clear: true}) %>')).to eq('{% user.merge!({clear: true}) %}')
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
      it "/ end" do
        expect(@helper.preserve_conditionals('<% unless foo %>')).to eq('{% if !( foo ) %}')
        expect(@helper.preserve_conditionals('<% unless foo == bar - 1 %>')).to eq('{% if !( foo == bar - 1 ) %}')
      end

      it "/ else / end" do
        expect(@helper.preserve_conditionals('<% unless foo == bar %>this<% else %>that<% end %>')).to eq('{% if !( foo == bar ) %}this{% else %}that{% end %}')
      end
    end
  end

  #-- Loops --

  describe "loops" do
    it "preserves each loops as for loops" do
      h = {
        "<% cats.each do |cat| %>" => "{% for cat in cats %}",
        "<% cats.each do | cat | %>" => "{% for cat in cats %}",
        "<% end %>" => "{% end %}"
      }
      h.each do |key, value|
        expect(@helper.preserve_loops(key)).to eq(value)
      end
    end

    it "preserves each_with_index" do
      h = {
        "<% cats.each_with_index do | cat , i | %>" => "{% for cat in cats with: {@index: i} %}",
        "<% cats.each_with_index do |cat, i| %>" => "{% for cat in cats with: {@index: i} %}",
        "<% cats.each_with_index do |cat,i| %>" => "{% for cat in cats with: {@index: i} %}"
      }
      h.each do |key, value|
        expect(@helper.preserve_loops(key)).to eq(value)
      end
    end
  end

  #-- Helpers --

  describe "Helpers use statements syntax, not output" do
    it "includes button" do
      expect(@helper.preserve_erb_code("<%= button 'foo', '#' %>")).to eq("{% button 'foo', '#' %}")
      expect(@helper.preserve_erb_code("<%= button 'foo', '#', color: 'blue' %>")).to eq("{% button 'foo', '#', color: 'blue' %}")
    end

    it "includes image_tag" do
      expect(@helper.preserve_erb_code("<%= image_tag 'photo.jpg', width: 100, alt: 'caption' %>")).to eq("{% image_tag 'photo.jpg', width: 100, alt: 'caption' %}")
      expect(@helper.preserve_erb_code('<%= image_tag "#{user}-photo.jpg", width: 100, alt: "caption" %>')).to eq('{% image_tag "#{user}-photo.jpg", width: 100, alt: "caption" %}')
    end
  end

  #-- Partials --

  describe "partials are converted to friendlier include syntax" do
    it "with locals" do
      expect(@helper.convert_partials_to_includes("{{ partial :'foo', locals: bar }}")).to eq("{% include 'foo' with: bar %}")
      expect(@helper.convert_partials_to_includes("{{ partial :'foo', locals:bar }}")).to eq("{% include 'foo' with:bar %}")
      expect(@helper.convert_partials_to_includes("{{ partial :'foo', locals: {cat: cat} }}")).to eq("{% include 'foo' with: {cat: cat} %}")

    end

    it "without locals" do
      expect(@helper.convert_partials_to_includes("{{ partial :'foo' }}")).to eq("{% include 'foo' %}")
      expect(@helper.convert_partials_to_includes("{{ partial :foo }}")).to eq("{% include foo %}")
    end
  end

  describe "multiple statements on one line" do
    it "does not match too early" do
      h = {
        "<% if %>this<% else %>that<%end%>" => "{% if %}this{% else %}that{% end %}",
        "<% if i==0 %><%= partial :foo %><% else %><%= partial :bar %><% end %>" => "{% if i==0 %}{% include foo %}{% else %}{% include bar %}{% end %}"
      }
      h.each do |key, value|
        expect(@helper.preserve_erb_code(key)).to eq(value)
      end
    end
  end

end
