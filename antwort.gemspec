Gem::Specification.new do |s|
  s.name        = 'antwort'
  s.version     = '0.0.1'
  s.date        = '2014-08-13'
  s.summary     = 'Antwort Generator'
  s.description = 'E-Mail development, build and test system.'
  s.authors     = ['Julie Ng']
  s.email       = 'hello@antwort.co'
  s.files       = ['lib/antwort.rb']
  s.homepage    = 'https://antwort.co'
  s.license     = 'MIT'

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
end
