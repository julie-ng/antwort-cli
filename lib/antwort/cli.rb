require 'antwort'
require 'thor'

module Antwort
  class CLI < Thor
    desc 'init PROJECT_NAME', 'Initializes a new project'
    def init(project_name)
      puts 'Initializing project...'
    end
  end
end
