require 'thor'

module Antwort
  class CLI < Thor
    include Thor::Actions

    class_option :version, type: :boolean

    def self.source_root
      File.expand_path('../../template', File.dirname(__FILE__))
    end

    desc 'init PROJECT_NAME', 'Initializes a new Antwort Email project'
    method_option :key,
                  type: :string,
                  required: true,
                  desc: 'API key of the offsides gem server'
    method_option :git,
                  type: :boolean,
                  default: true,
                  desc: 'Initializes git repo if set to true'
    method_option :bundle,
                  type: :boolean,
                  default: true,
                  desc: 'Runs bundle command in new repo'
    def init(project_name)
      @project_name = project_name
      @api_key = options[:key]
      copy_project
      initialize_git_repo if options[:git]
      run_bundler if options[:bundle]
      say "New project initialized in: ./#{project_directory}/", :green
    end

    desc 'new EMAIL_ID', 'Creates a new email template'
    def new(email_id)
      @email_id = email_id
      copy_email
      say "New email template created in: ./emails/#{email_directory}/", :green
    end

    desc 'upload EMAIL_ID', 'Uploads email assets to AWS S3'
    method_option :force,
                  type: :boolean,
                  default: false,
                  aliases: '-f',
                  desc: 'Overwrites existing files on the server'
    def upload(email_id)
      @email_id = email_id
      if confirms_upload?
        upload_mail
        puts 'Upload complete.'
      else
        say 'Upload aborted. ', :red
        say 'No files deleted or replaced.'
      end
    end

    desc 'server', 'Starts http://localhost:9292 server for coding and previewing emails'
    method_option :port,
                  type: :string,
                  default: 9292,
                  desc: 'Port number of server'
    def server
      require 'antwort'
      Antwort::Server.run!
    end

    desc 'build EMAIL_ID', 'Builds email markup and inlines CSS from source'
    method_option aliases: 'b'
    def build(email_id)
      require 'antwort'
      Antwort::Builder.new(template: email_id).build
    end

    desc 'version','ouputs version number'
    def version
      puts "Version: #{Antwort::VERSION}" if options[:version]
    end

    default_task :version

    attr_reader :project_name, :email_id

    no_commands do
      def confirms_upload?
        options[:force] ||
          yes?("Upload will replace existing #{email_id} assets on server, ok? (y/n)")
      end

      def upload_mail
        Upload.new(email_id).upload
      end

      def copy_email
        directory 'email/css',
                  File.join('assets', 'css', email_directory)
        directory 'email/images',
                  File.join('assets', 'images', email_directory)
        copy_file 'email/email.html.erb',
                  File.join('emails', email_directory, 'index.html.erb')
      end

      def copy_project
        directory 'project', project_directory
      end

      def initialize_git_repo
        inside(project_directory) do
          run('git init .')
        end
      end

      def run_bundler
        inside(project_directory) do
          run('bundle')
        end
      end

      def email_directory
        email_id.downcase.gsub(/([^A-Za-z0-9_\/-]+)|(--)/, '')
      end

      def project_directory
        project_name.downcase.gsub(/([^A-Za-z0-9_\/-]+)|(--)/, '')
      end
    end
  end
end
