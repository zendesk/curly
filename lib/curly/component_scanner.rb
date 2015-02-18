require 'curly/attribute_scanner'

module Curly
  class ComponentScanner
    def self.scan(component)
      first, rest = component.strip.split(/\s+/, 2)
      contexts = first.split(":")
      name_and_identifier = contexts.pop

      name, identifier = name_and_identifier.split(".", 2)

      if identifier && identifier.end_with?("?")
        name += "?"
        identifier = identifier[0..-2]
      end

      attributes = AttributeScanner.scan(rest)

      [name, identifier, attributes, contexts]
    end
  end
end
