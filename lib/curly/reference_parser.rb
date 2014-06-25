require 'curly/attribute_parser'

module Curly
  class ReferenceParser
    def self.parse(reference)
      name, rest = reference.split(/\s+/, 2)
      method, argument = name.split(".", 2)
      attributes = AttributeParser.parse(rest)

      [method, argument, attributes]
    end
  end
end
