require 'thor'
require 'fileutils'

module Antwort
  class CLI < Thor
    desc 'init PROJECT_NAME', 'Initializes a new Antwort project'
    def init(project_name)
      @project_name = project_name
      copy_project
      run_bundler
      say "Antwort project sucessfully initialized in directory #{project_dir}"
    end

    protected

    attr_reader :project_name

    def copy_project
      say 'Copying template...'
      template_dir = File.expand_path('../../template', File.dirname(__FILE__))
      FileUtils.copy_entry(template_dir, project_dir)
    end

    def run_bundler
      say 'Running bundler...'
      `cd #{project_dir} && bundle install`
    end

    def project_dir
      "./#{project_name}"
    end
  end
end
