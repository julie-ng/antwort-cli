require 'fileutils'
require 'tilt'
require 'roadie'
require 'thor/shell'

module Antwort
  class Builder
    include Thor::Shell
    include Antwort::Helpers
    include Antwort::CLIHelpers
    include Antwort::LogicHelpers
    include Antwort::MarkupSanitizers

    attr_reader :template_name, :build_id, :build_dir, :markup_dir, :source_dir, :scss_dir, :asset_server, :css, :css_style

    def initialize(attrs = {})
      @template_name = attrs[:email]
      @build_id      = attrs[:id]
      @build_dir     = "./build/#{template_name}-#{build_id}"
      @markup_dir    = "#{build_dir}/source"
      @source_dir    = "./emails/#{template_name}"
      @scss_dir      = "./assets/css/#{template_name}"
      @css_style     = attrs['css-style'].to_sym
      @asset_server  = ENV['ASSET_SERVER'] || '/assets'
      post_initialize(attrs)
    end

    def post_initialize(*)
      nil
    end

    def create_build_directories
      return if Dir.exist? build_dir
      Dir.mkdir "build" unless Dir.exist? "./build"
      Dir.mkdir(build_dir)
      Dir.mkdir("#{build_dir}/source")
    end

    def build
    end

    def load_css
      css_file = "#{markup_dir}/inline.css"
      build_css unless File.file? css_file
      css = File.read(css_file)
      css
    end

    def build_css
      compile_scss(source: "#{scss_dir}/inline.scss", destination: "#{markup_dir}/inline.css")
      compile_scss(source: "#{scss_dir}/include.scss", destination: "#{markup_dir}/include.css")
      @css = load_css
    end

    def compile_scss(attrs = {})
      source_file      = attrs[:source]
      destination_file = attrs[:destination]

      if File.file? source_file
        content = Tilt::ScssTemplate.new(source_file, style: @css_style).render
        create_file(content: content, path: destination_file)
      else
        say 'Build failed. ', :red
        say "#{source_file}.scss for #{template_name} not found."
      end
    end

    def create_file(attrs)
      content = attrs[:content]
      path    = attrs[:path]

      file = File.new(path, 'w')
      file.write(content)
      file.close
      say '    create  ', :green
      say path.gsub(/\A.\//, '')
      file
    end

    def use_asset_server(markup = '')
      replaced = "#{asset_server}/"
      output = markup.gsub('/assets/', replaced)
      output
    end

    def flatten_inlined_css(markup)
      copy = ''

      # loop through lines so we have the line number
      markup.lines.each_with_index do |line, i|
        f = Flattener.new(line).flatten
        if f.flattened?
          say " flattened  CSS #{f.flattened_keys} ", :yellow
          say "#{i}: #{f.source.strip}"
          copy << f.flattened
        else
          copy << f.source
        end
      end
      copy
    end
  end
end
