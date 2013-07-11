require 'strscan'

module Curly

  # Scans Curly templates for tokens.
  #
  # The Scanner goes through the template piece by piece, extracting tokens
  # until the end of the template is reached.
  #
  class Scanner
    REFERENCE_REGEX = %r(\{\{[\w\.]+\}\})
    COMMENT_REGEX = %r(\{\{!.*\}\})
    COMMENT_LINE_REGEX = %r(\s*#{COMMENT_REGEX}\s*\n)

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
      scan_reference ||
        scan_comment_line ||
        scan_comment ||
        scan_text ||
        scan_remainder
    end

    # Scans a reference token, if a reference is the next token in the template.
    #
    # Returns an Array representing the token, or nil if no reference token can
    #   be found at the current position.
    def scan_reference
      if value = @scanner.scan(REFERENCE_REGEX)
        # Return the reference name excluding "{{" and "}}".
        [:reference, value[2..-3]]
      end
    end

    # Scans a comment line token, if a comment line is the next token in the
    # template.
    #
    # Returns an Array representing the token, or nil if no comment line token
    #   can be found at the current position.
    def scan_comment_line
      if value = @scanner.scan(COMMENT_LINE_REGEX)
        # Returns the comment excluding "{{!" and "}}".
        [:comment_line, value[3..-4]]
      end
    end

    # Scans a comment token, if a comment is the next token in the template.
    #
    # Returns an Array representing the token, or nil if no comment token can
    #   be found at the current position.
    def scan_comment
      if value = @scanner.scan(COMMENT_REGEX)
        # Returns the comment excluding "{{!" and "}}".
        [:comment, value[3..-3]]
      end
    end

    # Scans a text token, if a text is the next token in the template.
    #
    # Returns an Array representing the token, or nil if no text token can
    #   be found at the current position.
    def scan_text
      if value = @scanner.scan_until(/\{\{/m)
        # Rewind the scanner until before the "{{"
        @scanner.pos -= 2

        # Return the text up until "{{".
        [:text, value[0..-3]]
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
  end
end
