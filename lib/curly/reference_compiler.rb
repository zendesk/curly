module Curly
  class ReferenceCompiler
    attr_reader :presenter_class, :method

    def initialize(presenter_class, method)
      @presenter_class, @method = presenter_class, method
    end

    def compile(method, argument)
      unless presenter_class.method_available?(method)
        raise Curly::InvalidReference.new(method)
      end

      code = "presenter.#{method}"

      if required_parameter?
        if argument.nil?
          raise Curly::Error, "`#{method}` requires a parameter"
        end

        code << "(#{argument.inspect})"
      elsif optional_parameter?
        code << "(#{argument.inspect})" unless argument.nil?
      elsif invalid_signature?
        raise Curly::Error, "`#{method}` is not a valid reference method"
      elsif !argument.nil?
        raise Curly::Error, "`#{method}` does not take a parameter"
      end

      code
    end

    private

    def invalid_signature?
      params.size > 1
    end

    def required_parameter?
      params.map(&:first) == [:req]
    end

    def optional_parameter?
      params.map(&:first) == [:opt]
    end

    def params
      presenter_class.instance_method(method).parameters
    end
  end
end
