require 'active_support/all'

if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
end

require 'curly'
