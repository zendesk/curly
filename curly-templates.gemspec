require './lib/curly/version'

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'curly-templates'
  s.version           = Curly::VERSION

  s.summary     = "Free your views!"
  s.description = "A view layer for your Rails apps that separates structure and logic."
  s.license     = "apache2"

  s.authors  = ["Daniel Schierbeck"]
  s.email    = 'daniel.schierbeck@gmail.com'
  s.homepage = 'https://github.com/zendesk/curly'

  s.required_ruby_version = ">= 2.7"

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency("actionpack", [">= 4.2", "< 7.1"])
  s.add_dependency("sorted_set")

  s.add_development_dependency("railties", [">= 4.2", "< 7.1"])
  s.add_development_dependency("rake")
  s.add_development_dependency("rspec", ">= 3")

  s.files      = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(perf|spec)/}) }
  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
