
desc 'Builds Markup from template (required: template=template_name})'
task :build do
  puts "build"


  foo = Antwort::Builder.new({template: 'foo'})

  # build_template ENV['template']
end

