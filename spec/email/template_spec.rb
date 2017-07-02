require 'spec_helper'

describe Antwort::EmailTemplate do
  let(:demo)          { Antwort::EmailTemplate.new('1-demo') }
  let(:no_layout)     { Antwort::EmailTemplate.new('2-no-layout') }
  let(:no_title)      { Antwort::EmailTemplate.new('3-no-title') }
  let(:custom_layout) { Antwort::EmailTemplate.new('4-custom-layout') }
  let(:no_images)     { Antwort::EmailTemplate.new('no-images') }

  describe 'Initialization' do
    it 'has a name' do
      expect(demo.name).to eq('1-demo')
    end

    it 'has a path' do
      expect(demo.path).to eq('emails/1-demo')
    end

    it 'has a index file' do
      expect(demo.file).to eq('emails/1-demo/index.html.erb')
    end
  end

  describe 'body attribute' do
    context 'with YAML front matter' do
      it 'ignores front matter' do
        four = '<p>Email four has a custom layout.</p>'
        expect(custom_layout.body).to eq(four)
      end
    end
    context 'without YAML front matter' do
      it 'receives file as body' do
        three = '<h1>Hello Three</h1>'
        expect(no_title.body).to eq(three)
      end
    end
  end

  describe 'title attribute' do
    context 'with a title' do
      it 'returns the title' do
        expect(demo.title).to eq('Email One')
      end
    end

    context 'without a title' do
      it "defaults to 'Untitled'" do
        expect(no_title.title).to eq('Untitled')
      end
    end
  end

  describe 'data attribute' do
    context 'with a YAML file' do
      it 'sets to YAML data' do
        expect(demo.data[:foo].length).to eq(2)
        expect(demo.data[:foo].first).to eq(title: 'foo')
        expect(demo.data[:foo].last).to eq(title: 'bar')
      end
    end

    context 'without a YAML file' do
      it 'defaults to empty hash' do
        expect(no_title.data).to eq({})
      end
    end
  end

  describe "layout" do
    it "defaults to :'emails/shared/layout'" do
      expect(demo.layout).to eq(:'emails/shared/layout')
    end

    it 'can be a custom layout' do
      expect(custom_layout.layout).to eq(:'emails/4-custom-layout/layout')
    end

    it 'can be false (i.e. has no layout)' do
      expect(no_layout.layout).to be false
    end
  end

  it 'has a url helper' do
    expect(demo.url).to eq('/template/1-demo')
  end

  describe 'API' do
    it '`#has_images?`' do
      expect(demo.has_images?).to be true
      expect(Antwort::EmailTemplate.new('shared').has_images?).to be true
      expect(no_images.has_images?).to be false
    end

    it "`#images` lists all images in template's assets" do
      expect(demo.images).to eq ['placeholder.png']
      expect(Antwort::EmailTemplate.new('shared').images).to eq ['placeholder-grey.png', 'placeholder-white.png']
      expect(Antwort::EmailTemplate.new('no-images').images).to eq []
    end

    it '`#image_path` returns path for an image' do
      expect(demo.image_path('placeholder.png')).to eq 'assets/images/1-demo/placeholder.png'
      expect(demo.image_path('does-not-exist.png')).to be nil
    end

    it '`#partials` lists all partials of the template' do
      expect(demo.partials).to eq ['_bar.erb', '_foo.erb']
      expect(no_layout.partials).to eq []
    end

    it '`#last_build`' do
      # TODO: gets generated locally but not in CI
      # expect(demo.last_build).to eq('1-demo-123')

      # Already exists in fixtures and is found
      demo2 = Antwort::EmailTemplate.new('demo')
      expect(demo2.last_build).to eq('demo-20160102')
    end
  end
end
