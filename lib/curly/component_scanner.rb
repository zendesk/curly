require 'curly/attribute_scanner'

module Curly
  class ComponentScanner
    def self.scan(component)
      first, rest = component.split(/\s+/, 2)
      name, identifier = first.split(".", 2)

      if identifier && identifier.end_with?("?")
        name += "?"
        identifier = identifier[0..-2]
      end

      attributes = AttributeScanner.scan(rest)

      [name, identifier, attributes]
    end
  end
end
