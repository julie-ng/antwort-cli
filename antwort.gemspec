# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'antwort/version'

Gem::Specification.new do |s|
  s.name        = 'antwort'
  s.version     = Antwort::VERSION
  s.summary     = 'Antwort Generator'
  s.description = 'E-Mail development, build and test system.'
  s.authors     = ['Julie Ng']
  s.email       = 'hello@antwort.co'
  s.homepage    = 'https://antwort.co'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
  s.required_ruby_version = '~> 2.0'

  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'sinatra-contrib'
  s.add_runtime_dependency 'sinatra-partial'
  s.add_runtime_dependency 'dotenv'
  s.add_runtime_dependency 'htmlentities'
  s.add_runtime_dependency 'mail'
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'roadie'

  s.add_runtime_dependency 'sass'
  s.add_runtime_dependency 'sprockets'
  s.add_runtime_dependency 'sprockets-sass'

  s.add_runtime_dependency 'thin'
  s.add_runtime_dependency 'rack-livereload'
  s.add_runtime_dependency 'guard-livereload'
  s.add_runtime_dependency 'fog'

  s.add_development_dependency 'pry'
end
