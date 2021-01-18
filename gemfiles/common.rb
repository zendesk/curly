source 'https://rubygems.org'

gemspec path: '../'

platform :ruby do
  gem 'yard'
  gem 'yard-tomdoc'
  gem 'redcarpet'
  gem 'github-markup'
  gem 'rspec-rails', require: false
  gem 'benchmark-ips', require: false
  gem 'stackprof', require: false
end
