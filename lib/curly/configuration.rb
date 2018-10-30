module Curly
  extend self

  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield(configuration)
  end

  def configuration=(c)
    @configuration = c
  end

  def reset
    @configuration = Configuration.new
  end

  class Configuration
    attr_accessor :cache_store

    def initialize
      @cache_store = nil
    end
  end
end
