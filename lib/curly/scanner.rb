require 'strscan'
require 'curly/component_scanner'
require 'curly/syntax_error'

module Curly

  # Scans Curly templates for tokens.
  #
  # The Scanner goes through the template piece by piece, extracting tokens
  # until the end of the template is reached.
  class Scanner
    CURLY_START = /\{\{/
    CURLY_END = /\}\}/

    ESCAPED_CURLY_START = /\{\{\{/

    COMMENT_MARKER = /!/
    CONTEXT_BLOCK_MARKER = /@/
    CONDITIONAL_BLOCK_MARKER = /(#if |#)/
    ELSE_BLOCK_MARKER = /else}}/
    INVERSE_BLOCK_MARKER = /(#unless |\^)/
    COLLECTION_BLOCK_MARKER = /\*/
    CONDITIONAL_END_BLOCK_MARKER = /\/if/
    INVERSE_CONDITIONAL_END_BLOCK_MARKER = /\/unless/
    END_BLOCK_MARKER = /\//


    # Scans a Curly template for tokens.
    #
    # source - The String source of the template.
    #
    # Examples
    #
    #   Curly::Scanner.scan("hello {{name}}!")
    #   #=> [[:text, "hello "], [:component, "name"], [:text, "!"]]
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
        scan_tag or syntax_error!
      end
    end

    def scan_tag
      if @scanner.scan(COMMENT_MARKER)
        scan_comment
      elsif @scanner.scan(INVERSE_BLOCK_MARKER)
        scan_inverse_block_start
      elsif @scanner.scan(CONDITIONAL_BLOCK_MARKER)
        scan_conditional_block_start
      elsif @scanner.scan(ELSE_BLOCK_MARKER)
        scan_else_marker
      elsif @scanner.scan(CONTEXT_BLOCK_MARKER)
        scan_context_block_start
      elsif @scanner.scan(COLLECTION_BLOCK_MARKER)
        scan_collection_block_start
      elsif @scanner.scan(CONDITIONAL_END_BLOCK_MARKER)
        scan_conditional_block_end
      elsif @scanner.scan(INVERSE_CONDITIONAL_END_BLOCK_MARKER)
        scan_inverse_conditional_block_end
      elsif @scanner.scan(END_BLOCK_MARKER)
        scan_block_end
      else
        scan_component
      end
    end

    def scan_comment
      if value = scan_until_end_of_curly
        [:comment, value]
      end
    end

    def scan_conditional_block_start
      if value = scan_until_end_of_curly
        name, identifier, attributes = ComponentScanner.scan(value)

        [:conditional_block_start, name, identifier, attributes]
      end
    end

    def scan_else_marker
      [:else_block_start, nil, nil]
    end

    def scan_context_block_start
      if value = scan_until_end_of_curly
        name, identifier, attributes = ComponentScanner.scan(value)

        [:context_block_start, name, identifier, attributes]
      end
    end

    def scan_collection_block_start
      if value = scan_until_end_of_curly
        name, identifier, attributes = ComponentScanner.scan(value)
        [:collection_block_start, name, identifier, attributes]
      end
    end

    def scan_inverse_block_start
      if value = scan_until_end_of_curly
        name, identifier, attributes = ComponentScanner.scan(value)
        [:inverse_conditional_block_start, name, identifier, attributes]
      end
    end

    def scan_conditional_block_end
      if scan_until_end_of_curly
        [:conditional_block_end, nil, nil]
      end
    end

    def scan_inverse_conditional_block_end
      if scan_until_end_of_curly
        [:inverse_conditional_block_end, nil, nil]
      end
    end

    def scan_block_end
      if value = scan_until_end_of_curly
        name, identifier, attributes = ComponentScanner.scan(value)
        [:block_end, name, identifier]
      end
    end

    def scan_component
      if value = scan_until_end_of_curly
        name, identifier, attributes = ComponentScanner.scan(value)
        [:component, name, identifier, attributes]
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
