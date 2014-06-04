module Curly
  class ReferenceCompiler
    attr_reader :presenter_class

    def initialize(presenter_class)
      @presenter_class = presenter_class
    end

    def compile(method, argument)
      unless presenter_class.method_available?(method)
        raise Curly::InvalidReference.new(method)
      end

      code = "presenter.#{method}"

      if required_parameter?(method)
        if argument.nil?
          raise Curly::Error, "`#{method}` requires a parameter"
        end

        code << "(#{argument.inspect})"
      elsif optional_parameter?(method)
        code << "(#{argument.inspect})" unless argument.nil?
      elsif !argument.nil?
        raise Curly::Error, "`#{method}` does not take a parameter"
      end

      code
    end

    private

    def required_parameter?(method)
      params_for(method).map(&:first) == [:req]
    end

    def optional_parameter?(method)
      params_for(method).map(&:first) == [:opt]
    end

    def params_for(method)
      presenter_class.instance_method(method).parameters
    end
  end
end
