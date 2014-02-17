module Curly
  class InvalidBlockError < StandardError

    attr_reader :reference

    def initialize(reference)
      @reference = reference
    end

  end

  class IncompleteBlockError < InvalidBlockError

    def message
      "error compiling `{{##{@reference}}}`: Conditional block must be terminated with `{{/#{@reference}}}}`"
    end

  end

  class IncorrectEndingError < InvalidBlockError

    def initialize(reference, last_block)
      @reference, @last_block = reference, last_block
    end

    def message
      "error compiling `{{##{@last_block}}}`: expected `{{/#{@last_block}}}`, got `{{/#{@reference}}}`"
    end

  end

end
