require 'curly/error'

module Curly
  class SyntaxError < Error
    def initialize(position, source, line)
      @position, @source, @line = position, source, line
    end

    def message
      start = [@position - 8, 0].max
      stop = [@position + 8, @source.length].min
      snippet = @source[start..stop].strip
      "invalid syntax near `#{snippet}` on line #{@line} in " \
        "template:\n\n#{@source}\n"
    end
  end
end
