require 'curly/attribute_parser'

module Curly
  class ComponentParser
    def self.parse(component)
      first, rest = component.split(/\s+/, 2)
      name, identifier = first.split(".", 2)
      attributes = AttributeParser.parse(rest)

      [name, identifier, attributes]
    end
  end
end
