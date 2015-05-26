require 'curly/error'

module Curly
  class PresenterNameError < Error
    attr_reader :original_exception, :name

    def initialize(original_exception, name)
      @name = name
      @original_exception = original_exception
    end

    def message
      "cannot use context `#{name}`, could not find matching presenter class"
    end
  end
end
