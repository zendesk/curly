module Curly
  AttributeError = Class.new(Curly::Error)

  class AttributeParser
    def self.parse(string)
      return {} if string.nil?
      new(string).parse
    end

    def initialize(string)
      @scanner = StringScanner.new(string)
    end

    def parse
      attributes = scan_attributes
      Hash[attributes]
    end

    private

    def scan_attributes
      attributes = []

      while attribute = scan_attribute
        attributes << attribute
      end

      attributes
    end

    def scan_attribute
      skip_whitespace

      return if @scanner.eos?

      name = scan_name or raise AttributeError
      value = scan_value or raise AttributeError

      [name, value]
    end

    def scan_name
      name = @scanner.scan(/\w+=/)
      name && name[0..-2]
    end

    def scan_value
      scan_unquoted_value || scan_single_quoted_value || scan_double_quoted_value
    end

    def scan_unquoted_value
      @scanner.scan(/\w+/)
    end

    def scan_single_quoted_value
      value = @scanner.scan(/'[^']*'/)
      value && value[1..-2]
    end

    def scan_double_quoted_value
      value = @scanner.scan(/"[^"]*"/)
      value && value[1..-2]
    end

    def skip_whitespace
      @scanner.skip(/\s*/)
    end
  end
end
