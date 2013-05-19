require 'active_support/all'

if ENV['ci']
  require 'coveralls'
  Coveralls.wear!
end

require 'curly'
