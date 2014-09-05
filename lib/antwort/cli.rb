require 'thor'

module Antwort
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      File.expand_path('../../template', File.dirname(__FILE__))
    end

    desc 'init PROJECT_NAME', 'Initializes a new Antwort project'
    method_option :key, type: :string, desc: 'API key of the offsides gem server'
    def init(project_name)
      @project_name = project_name
      @api_key = options[:key]
      copy_project
      initialize_git_repo
      run_bundler
      say "Antwort project sucessfully initialized in directory #{project_directory}", :green
    end

    protected

    attr_reader :project_name

    def copy_project
      say 'Copying template...'
      directory 'project', project_directory
    end

    def initialize_git_repo
      inside(project_directory) do
        run('git init .')
      end
    end

    def run_bundler
      say 'Running bundler...'
      inside(project_directory) do
        run('bundle')
      end
    end

    def project_directory
      project_name.downcase.gsub(/[^a-z|\-|\_]/, '')
    end
  end
end
