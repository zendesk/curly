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
      if reference = scan_reference
        [:reference, reference]
      elsif comment = scan_comment_line
        [:comment_line, comment]
      elsif comment = scan_comment
        [:comment, comment]
      elsif text = scan_text
        [:text, text]
      else
        text = scan_remainder
        [:text, text]
      end
    end

    def scan_reference
      if reference = @scanner.scan(REFERENCE_REGEX)
        # Return the text excluding the "{{}}"
        reference[2..-3]
      end
    end

    def scan_comment_line
      if comment = @scanner.scan(COMMENT_LINE_REGEX)
        comment[3..-4]
      end
    end

    def scan_comment
      if comment = @scanner.scan(COMMENT_REGEX)
        comment[3..-3]
      end
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
