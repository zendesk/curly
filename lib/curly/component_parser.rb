require 'curly/attribute_parser'

module Curly
  class ComponentParser
    def self.parse(component)
      name, rest = component.split(/\s+/, 2)
      method, argument = name.split(".", 2)
      attributes = AttributeParser.parse(rest)

      [method, argument, attributes]
    end
  end
end
