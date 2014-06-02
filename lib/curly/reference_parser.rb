module Curly
  class ReferenceParser

    VALUE_MATCH = %{(?:
                      (?:\"((?:\\"|.)*?)\")
                    | ([[:word:]\.]+)
                  )}

    def self.parse(value)
      new(value).parse
    end

    def initialize(reference)
      @reference = reference
      @scanner = StringScanner.new(reference)
    end

    def parse
      tokens = [
        @scanner.scan(/[^. ]+/)
      ]

      tokens.push(scan_arguments).compact!
      modifier = scan_modifier
      tokens[0] << modifier if modifier
      syntax_error! unless @scanner.eos?
      tokens
    end

    private

    def scan_arguments
      scan_singular || scan_keywords
    end

    def scan_modifier
      if @scanner.scan(/\?/)
        "?"
      end
    end

    def scan_singular
      if @scanner.scan(/\.#{VALUE_MATCH}/x)
        @scanner[1] || @scanner[2]
      end
    end

    def scan_keywords
      if @scanner.scan(/ /)
        keywords = []
        keypair = scan_keypair

        while keypair
          keywords << keypair
          keypair = scan_keypair
        end

        Hash[keywords]
      end
    end

    def scan_keypair
      return unless @scanner.scan(/\A\s*#{VALUE_MATCH}:/x)
      key = @scanner[1] || @scanner[2]
      return unless @scanner.scan(/\A\s*#{VALUE_MATCH}/x)
      value = @scanner[1] || @scanner[2]

      [key.gsub(/\\"/, "\""), value.gsub(/\\"/, "\"")]
    end

    def syntax_error!
      raise SyntaxError.new(@scanner.pos, @scanner.string)
    end

  end
end
