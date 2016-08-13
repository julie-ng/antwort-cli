module Antwort
  class CLI < Thor
    include Thor::Actions
    include Antwort::FileHelpers

    class_option :version, type: :boolean

    # set template source path for Thor
    def self.source_root
      File.expand_path('../../../template', File.dirname(__FILE__))
    end

    #-- init

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
      @user         = options[:user] if options[:user]
      @key          = options[:key] if options[:key]

      copy_project
      initialize_git_repo if options[:git]
      run_bundler if options[:bundle]
      say "New project initialized in: ./#{project_directory}/", :green
    end

    #-- new

    desc 'new [email_id]', 'Creates a new email template'
    method_option aliases: 'n'
    def new(email_id)
      @email_id = email_id
      copy_email
    end

    #-- list

    desc 'list', 'Lists all emails in the ./emails directory by id'
    method_option aliases: 'l'
    def list
      EmailCollection.new.list.each do |email_id|
        puts "- #{email_id}"
      end
    end

    #-- upload

    desc 'upload', 'Uploads email assets to AWS S3'
    method_option aliases: 'u'

    def upload(email_id)
      require 'antwort/cli/upload'
      Upload.new(email_id).upload
    end

    #-- send

    desc 'send [email_id]', 'Sends built email via SMTP'
    method_option :from,
                  type: :string,
                  default: ENV['SEND_FROM'],
                  aliases: '-f',
                  desc: 'Email address of sender'
    method_option :recipient,
                  type: :string,
                  default: ENV['SEND_TO'],
                  aliases: '-r',
                  desc: 'Email address of receipient(s). Split multiple recipients with a comma.'
    method_option :subject,
                  type: :string,
                  aliases: '-s',
                  desc: 'Email Subject. Defaults to <title> value if blank.'
    def send(email_id)
      require 'antwort/cli/send'
      build = last_build_by_id(email_id)

      if build.nil?
        say "   warning  ", :yellow
        say "No build found for '#{email_id}'. Building now..."
        build(email_id)
        build = last_build_by_id(email_id)
      end

      Send.new(build, options).send
    end

    #-- server

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

    #-- build

    desc 'build [email_id]', 'Builds email markup and inlines CSS from source'
    method_option aliases: 'b'
    method_option :all,
                  type: :boolean,
                  default: false,
                  aliases: '-a',
                  desc: 'Build all templates'
    method_option :partials,
                  type: :boolean,
                  default: false,
                  aliases: '-p',
                  desc: 'Build partials'
    method_option :'css-style',
                  type: :string,
                  default: 'expanded',
                  aliases: '-c',
                  desc: 'CSS output style'
    def build(email_id='')
      if (email_id.empty?)
        say 'Error: ', :red
        say 'build which email?'
        list
      else
        to_build = options[:all] ? EmailCollection.new.list : email_id
        Build.new(to_build, options).create!
        show_accuracy_warning if options[:partials]
      end
    end

    #-- prune

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

    #-- remove

    desc 'remove [email_id]', 'Removes an email, incl. its assets, styles and data'
    method_option :force,
              type: :boolean,
              default: false,
              aliases: '-f',
              desc: 'Removes an email, incl. its assets, styles and data'
    def remove(email_id)
      @email_id = email_id
      if confirms_remove?
        remove_email
      else
        say "Remove aborted."
      end
    end

    #-- version

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

      def confirms_remove?
        options[:force] || yes?("Are you sure you want to delete '#{email_id}', including its css, images and data? (y/n)")
      end

      def copy_email
        directory 'email/css',
                  File.join('assets', 'css', email_directory)
        directory 'email/images',
                  File.join('assets', 'images', email_directory)
        create_file! File.join('data', "#{email_id}.yml")
        copy_file 'email/email.html.erb',
                  File.join('emails', email_directory, 'index.html.erb')
      end

      def remove_email
        remove_file File.expand_path("./data/#{email_id}.yml")
        remove_dir File.expand_path("./assets/css/#{email_id}/")
        remove_dir File.expand_path("./assets/images/#{email_id}/")
        remove_dir File.expand_path("./emails/#{email_id}/")
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

      def create_id_from_timestamp
        stamp = Time.now.to_s
        stamp.split(' ')[0..1].join.gsub(/(-|:)/, '')
      end

      def show_accuracy_warning
        say ''
        say '** NOTE: Accuracy of Inlinied Partials **', :yellow
        say 'Partials do not have access to the full DOM tree. Therefore, nested CSS selectors, e.g. ".layout td",'
        say 'may not be matched for inlining. Always double check your code before use in production!'
      end
    end
  end
end
