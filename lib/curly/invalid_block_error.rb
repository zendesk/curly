module Curly
  class InvalidBlockError < Error
    attr_reader :reference

    def initialize(reference)
      @reference = reference
    end
  end
end
