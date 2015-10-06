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

  describe "conditionals" do
    it "preserves if x else y"
    it "preserves if x elsif y else z"
  end

  describe "loops" do
    it "preserves each loops as for loops"
  end

  describe "comments" do
    it "preserves erb comments" do
      expect(@helper.preserve_comments('<%# foo %>')).to eq('{# foo #}')
    end

    it "preserves comments despite leading/trailing spaces" do
      expect(@helper.preserve_comments('<% # foo %>')).to eq('{# foo #}')
    end
  end

  describe "variables" do
    it "preserves interpolated strings" do
      expect(@helper.preserve_variables('<%= "color: #{foo};" %>')).to eq('{{ "color: #{foo};" }}')
    end

    context "hashes" do
      it "preserves nested" do
        expect(@helper.preserve_variables('<%= foo[:bar] %>')).to eq('{{ foo.bar }}')
        expect(@helper.preserve_variables('<%= foo[:bar][:cat] %>')).to eq('{{ foo.bar.cat }}')
      end

      it "preseves sring keys" do
        expect(@helper.preserve_variables("<%= foo['bar'] %>")).to eq('{{ foo.bar }}')
      end
    end
  end

  describe "assignemnts" do
    it "preserves assginemnts" do
      expect(@helper.preserve_assignments('<% foo = "bar" %>')).to eq('{% set foo = "bar" %}')
    end

    it "resepects memoized assignemnts" do
      expect(@helper.preserve_assignments('<% foo ||= "bar" %>')).to eq('{% set foo = foo || "bar" %}')
    end
  end

end