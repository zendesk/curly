require './lib/curly/version'

Gem::Specification.new do |s|
  s.name              = 'curly-templates'
  s.version           = Curly::VERSION

  s.summary     = "Free your views!"
  s.description = "A view layer for your Rails apps that separates structure and logic."
  s.license     = "apache2"

  s.authors  = ["Daniel Schierbeck"]
  s.email    = 'daniel.schierbeck@gmail.com'
  s.homepage = 'https://github.com/zendesk/curly'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]

  s.required_ruby_version = ">= 3.1"

  s.add_dependency("actionpack", [">= 6.1", "< 7.2"])
  s.add_dependency("sorted_set")

  s.add_development_dependency("railties", [">= 5.1", "< 7.2"])
  s.add_development_dependency("rake")
  s.add_development_dependency("rspec", ">= 3")

  s.files      = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(perf|spec)/}) }
  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
