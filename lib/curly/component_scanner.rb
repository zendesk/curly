require 'curly/attribute_scanner'

module Curly
  class ComponentScanner
    def self.scan(component)
      first, rest = component.split(/\s+/, 2)
      name, identifier = first.split(".", 2)
      attributes = AttributeScanner.scan(rest)

      [name, identifier, attributes]
    end
  end
end
