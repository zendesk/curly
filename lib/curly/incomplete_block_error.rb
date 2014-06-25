module Curly
  class IncompleteBlockError < Error
    def initialize(component)
      @component = component
    end

    def message
      "error compiling `{{##{@component}}}`: conditional block must be terminated with `{{/#{@component}}}}`"
    end
  end
end
