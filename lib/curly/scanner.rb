require 'strscan'

module Curly
  class Scanner
    REFERENCE_REGEX = %r(\{\{([\w\.]+)\}\})
    COMMENT_REGEX = %r(\{\{\!\s*(.*)\s*\}\})
    COMMENT_LINE_REGEX = %r(\s*#{COMMENT_REGEX}\s*\n)

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

    def scan_token
      scan_reference ||
        scan_comment_line ||
        scan_comment ||
        scan_text ||
        scan_remainder
    end

    def scan_reference
      if value = @scanner.scan(REFERENCE_REGEX)
        # Return the text excluding the "{{}}"
        [:reference, value[2..-3]]
      end
    end

    def scan_comment_line
      if value = @scanner.scan(COMMENT_LINE_REGEX)
        [:comment_line, value[3..-4]]
      end
    end

    def scan_comment
      if value = @scanner.scan(COMMENT_REGEX)
        [:comment, value[3..-3]]
      end
    end

    def scan_text
      if value = @scanner.scan_until(/\{\{/m)
        # Rewind the scanner until before the "{{"
        @scanner.pos -= 2

        # Return the text up until "{{"
        [:text, value[0..-3]]
      end
    end

    def scan_remainder
      if value = @scanner.scan(/.+/m)
        [:text, value]
      end
    end
  end
end
