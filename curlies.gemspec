Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'curlies'
  s.version           = '0.0.1'
  s.date              = '2013-01-21'

  s.summary     = "Free your views!"
  s.description = "A view layer for your Rails apps that separates structure and logic."

  s.authors  = ["Daniel Schierbeck"]
  s.email    = 'dasch@zendesk.com'
  s.homepage = 'http://github.com/zendesk/curlies'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README LICENSE]

  s.add_dependency("actionpack", "~> 3.2.11")

  # = MANIFEST =
  s.files = %w[
    README.md
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
