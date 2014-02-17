module Curly
  class InvalidReference < Error
    attr_reader :reference

    def initialize(reference)
      @reference = reference
    end

    def message
      "invalid reference `{{#{reference}}}'"
    end
  end
end
