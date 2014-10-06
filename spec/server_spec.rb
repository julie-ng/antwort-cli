require 'spec_helper'

describe 'Antwort Server' do

  def app
    Antwort::Server
  end

  describe "Index page" do
    it "is valid" do
      get '/'
      expect(last_response.status).to eq(200)
    end

    it "lists available templates by title, includes link" do
      get '/'
      expect(last_response.body).to include('Email One')
      expect(last_response.body).to include('Email Two')
      expect(last_response.body).to include('<a href="template/1-demo">')
      expect(last_response.body).to include('<a href="template/2-no-layout">')
    end
  end

  describe "Template show action" do

    it "shows email preview" do
      get '/template/1-demo'
      expect(last_response.body).to include('<h1>Hello One</h1>')
      expect(last_response.body).to include('<title>Email One</title>')
    end

    it "loads corresponding data yaml file" do
      get '/template/1-demo'
      expect(last_response.body).to include('foo')
      expect(last_response.body).to include('bar')
    end

    it "respects layout:false metadata attribute" do
      get '/template/2-no-layout'
      expect(last_response.body).not_to include('<body>')
    end

    it "has default title if none found" do
      get 'template/3-no-title'
      expect(last_response.body).to include('Untitled')
    end

    it "shows 404 error if template not found" do
      get '/template/does-not-exist'
      expect(last_response.status).to eq(404)
    end
  end

end