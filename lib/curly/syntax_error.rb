require 'curly/error'

module Curly
  class SyntaxError < Error
    def initialize(position, source)
      @position, @source = position, source
    end

    def message
      start   = [@position - 8, 0].max
      stop    = [@position + 8, @source.length].min
      snippet = @source[start..stop].strip
      line    = @source[0..@position].count("\n") + 1
      "invalid syntax near `#{snippet}` on line #{line} in " \
        "template:\n\n#{@source}\n"
    end
  end
end
