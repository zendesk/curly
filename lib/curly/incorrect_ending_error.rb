module Curly
  class IncorrectEndingError < Error
    def initialize(actual_block, expected_block)
      @actual_block, @expected_block = actual_block, expected_block
    end

    def message
      "compilation error: expected `{{/#{expected_block}}}`, got `{{/#{actual_block}}}`"
    end

    private

    def actual_block
      present_block(@actual_block)
    end

    def expected_block
      present_block(@expected_block)
    end

    def present_block(block)
      block.compact.join(".")
    end
  end
end
