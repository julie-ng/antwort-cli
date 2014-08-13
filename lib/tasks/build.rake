
desc 'Builds Markup from template (required: template=template_name})'
task :build do
  template = ENV['template'] ? ENV['template'] : 'newsletter'
  Antwort::Builder.new({template: template}).build
end

