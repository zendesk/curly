module Curly
  class ReferenceParser

    VALUE_MATCH = %{(?:
                      (?:("|')((?:\\"|\\'|.)*?)\1)
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
        @scanner[2] || @scanner[3]
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
      return unless @scanner.scan(/\A\s*#{VALUE_MATCH}\s*=/x)
      key = @scanner[2] || @scanner[3]
      return unless @scanner.scan(/\A\s*#{VALUE_MATCH}/x)
      value = @scanner[2] || @scanner[3]

      [normalize(key), normalize(value)]
    end

    def normalize(string)
      string.gsub(/\\"/, "\"").gsub(/\\'/, "\'")
    end

    def syntax_error!
      raise SyntaxError.new(@scanner.pos, @scanner.string)
    end

  end
end
