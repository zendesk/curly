require 'curly/error'

module Curly
  class SyntaxError < Error
    def initialize(position, source)
      @position, @source = position, source
    end

    def message
      start = [@position - 8, 0].max
      stop = [@position + 8, @source.length].min
      snippet = @source[start..stop].strip
      "invalid syntax near `#{snippet}` in template:\n\n#{@source}\n"
    end
  end
end
