module Curly
  class IncorrectEndingError < Error
    def initialize(reference, last_block)
      @reference, @last_block = reference, last_block
    end

    def message
      "error compiling `{{##{@last_block}}}`: expected `{{/#{@last_block}}}`, got `{{/#{@reference}}}`"
    end
  end
end
