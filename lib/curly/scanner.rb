require 'strscan'
require 'curly/syntax_error'

module Curly

  # Scans Curly templates for tokens.
  #
  # The Scanner goes through the template piece by piece, extracting tokens
  # until the end of the template is reached.
  #
  class Scanner
    CURLY_START = /\{\{/
    CURLY_END = /\}\}/

    ESCAPED_CURLY_START = /\{\{\{/

    COMMENT_MARKER = /!/

    # Scans a Curly template for tokens.
    #
    # source - The String source of the template.
    #
    # Example
    #
    #   Curly::Scanner.scan("hello {{name}}!")
    #   #=> [[:text, "hello "], [:reference, "name"], [:text, "!"]]
    #
    # Returns an Array of type/value pairs representing the tokens in the
    #   template.
    def self.scan(source)
      new(source).scan
    end

    def initialize(source)
      @scanner = StringScanner.new(source)
    end

    def scan
      tokens = []
      tokens << scan_token until @scanner.eos?
      tokens
    end

    private

    # Scans the next token in the template.
    #
    # Returns a two-element Array, the first element being the Symbol type of
    #   the token and the second being the String value.
    def scan_token
      scan_escaped_curly || scan_curly || scan_text
    end

    def scan_escaped_curly
      if @scanner.scan(ESCAPED_CURLY_START)
        [:text, "{{"]
      end
    end

    def scan_curly
      if @scanner.scan(CURLY_START)
        scan_reference_or_comment or syntax_error!
      end
    end

    def scan_reference_or_comment
      if @scanner.scan(COMMENT_MARKER)
        scan_comment
      else
        scan_reference
      end
    end

    def scan_comment
      if value = scan_until_end_of_curly
        [:comment, value]
      end
    end

    def scan_reference
      if value = scan_until_end_of_curly
        [:reference, value]
      end
    end

    def scan_text
      if value = scan_until_start_of_curly
        @scanner.pos -= 2
        [:text, value]
      else
        scan_remainder
      end
    end

    # Scans the remainder of the template and treats it as a text token.
    #
    # Returns an Array representing the token, or nil if no text is remaining.
    def scan_remainder
      if value = @scanner.scan(/.+/m)
        [:text, value]
      end
    end

    def scan_until_start_of_curly
      if value = @scanner.scan_until(CURLY_START)
        value[0..-3]
      end
    end

    def scan_until_end_of_curly
      if value = @scanner.scan_until(CURLY_END)
        value[0..-3]
      end
    end

    def syntax_error!
      raise SyntaxError.new(@scanner.pos, @scanner.string)
    end
  end
end
