module Curly
  class IncompleteBlockError < Error
    def initialize(reference)
      @reference = reference
    end

    def message
      "error compiling `{{##{@reference}}}`: conditional block must be terminated with `{{/#{@reference}}}}`"
    end
  end
end
