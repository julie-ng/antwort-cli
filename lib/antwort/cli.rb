require 'fileutils'
require 'thor'

module Antwort
  class CLI < Thor
    include Thor::Actions

    class_option :version, type: :boolean

    def self.source_root
      File.expand_path('../../template', File.dirname(__FILE__))
    end

    desc 'init [project_name]', 'Initializes a new Antwort Email project'
    method_option :user,
                  type: :string,
                  desc: 'Your username to antwort gem server'
    method_option :key,
                  type: :string,
                  desc: 'Your password to antwort gem server'
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
      @user = options[:user] if options[:user]
      @key = options[:key] if options[:key]
      copy_project
      initialize_git_repo if options[:git]
      run_bundler if options[:bundle]
      say "New project initialized in: ./#{project_directory}/", :green
    end

    desc 'new [email_id]', 'Creates a new email template'
    method_option aliases: 'n'
    def new(email_id)
      @email_id = email_id
      copy_email
    end

    desc 'list', 'Lists all emails in the ./emails directory by id'
    method_option aliases: 'l'
    def list
      available_emails.each { |e| puts "- #{e}" }
    end

    desc 'upload', 'Uploads email assets to AWS S3'
    method_option :images,
                  type: :string,
                  banner: '[folder]',
                  required: true,
                  aliases: '-i',
                  desc: 'Image assets folder to upload. [email_id] or \'shared\''
    method_option :force,
                  type: :boolean,
                  default: false,
                  aliases: '-f',
                  desc: 'Overwrites existing files on the server'
    method_option aliases: 'u'
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

    desc 'send [email_id]', 'Sends built email via SMTP'
    method_option :from,
                  type: :string,
                  default: ENV['SMTP_USERNAME'],
                  aliases: '-f',
                  desc: 'Email address of sender'
    method_option :recipient,
                  type: :string,
                  default: ENV['SEND_TO'],
                  aliases: '-r',
                  desc: 'Email address of receipient'
    method_option :subject,
                  type: :string,
                  default: 'Test Email',
                  aliases: '-s',
                  desc: 'Email Subject'
    def send(email_id)
      id = last_build_by_id(email_id)
      Send.new(id, options).send
    end

    desc 'server', 'Starts http://localhost:9292 server for coding and previewing emails'
    method_option :port,
                  type: :string,
                  default: 9292,
                  aliases: '-p',
                  desc: 'Port number of server'
    def server
      require 'antwort'
      Antwort::Server.run!(port: options[:port])
    end

    desc 'build [email_id]', 'Builds email markup and inlines CSS from source'
    method_option aliases: 'b'
    def build(email_id)
      require 'antwort'
      Antwort::Builder.new(template: email_id).build
    end

    desc 'prune', 'Removes all files in the ./build directory'
    method_option :force,
              type: :boolean,
              default: false,
              aliases: '-f',
              desc: 'Removes all files in the ./build directory'
    def prune
      if confirms_prune?
        build_dir = File.expand_path('./build')
        Dir.foreach(build_dir) do |f|
          next if f.to_s[0] == '.'
          say "   delete ", :red
          say "./build/#{f}/"
          FileUtils.rm_rf(File.expand_path("./build/#{f}"))
        end
      else
        say "prune aborted."
      end
    end

    desc 'version','Ouputs version number'
    def version
      puts "Version: #{Antwort::VERSION}" if options[:version]
    end

    default_task :version

    attr_reader :project_name, :email_id

    no_commands do

      def confirms_prune?
        options[:force] || yes?('Are you sure you want to delete all folders in the ./build directory? (y/n)')
      end

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

      def built_emails
        Dir.entries(File.expand_path('./build')).select { |f| !f.include? '.' }
      end

      def available_emails
        Dir.entries(File.expand_path('./emails')).select { |f| !f.include? '.' }
      end

      def last_build_by_id(email_id)
        built_emails.select { |f| f.include? email_id }.sort.last
      end
    end
  end
end
