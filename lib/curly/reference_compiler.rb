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

      if presenter_class.instance_method(method).arity == 1
        if argument.nil?
          raise Curly::Error, "`#{method}` requires a parameter"
        end

        code << "(#{argument.inspect})"
      elsif !argument.nil?
        raise Curly::Error, "`#{method}` does not take a parameter"
      end

      code
    end
  end
end
