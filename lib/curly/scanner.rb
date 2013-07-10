require 'strscan'

module Curly
  class Scanner
    REFERENCE_REGEX = %r(\{\{([\w\.]+)\}\})
    COMMENT_REGEX = %r(\{\{\!\s*(.*)\s*\}\})
    COMMENT_LINE_REGEX = %r(\s*#{COMMENT_REGEX}\s*\n)

    def initialize(source)
      @scanner = StringScanner.new(source)
    end

    def eos?
      @scanner.eos?
    end

    def scan_reference
      if reference = @scanner.scan(REFERENCE_REGEX)
        # Return the text excluding the "{{}}"
        reference[2..-3]
      end
    end

    def scan_comment_line
      @scanner.scan(COMMENT_LINE_REGEX)
    end

    def scan_comment
      @scanner.scan(COMMENT_REGEX)
    end

    def scan_text
      if text = @scanner.scan_until(/\{\{/m)
        # Rewind the scanner until before the "{{"
        @scanner.pos -= 2

        # Return the text up until "{{"
        text[0..-3]
      end
    end

    def scan_remainder
      @scanner.scan(/.+/m)
    end
  end
end
