module Curly
  class InvalidComponent < Error
    attr_reader :component

    def initialize(component)
      @component = component
    end

    def message
      "invalid component `{{#{component}}}'"
    end
  end
end
