module Curly
  class ComponentCompiler
    attr_reader :presenter_class, :component

    def self.compile(presenter_class, component)
      new(presenter_class, component).compile
    end

    def initialize(presenter_class, component)
      @presenter_class, @component = presenter_class, component
    end

    def compile
      unless presenter_class.component_available?(method)
        raise Curly::InvalidComponent.new(method)
      end

      validate_attributes!

      code = "presenter.#{method}("

      append_positional_argument(code)
      append_keyword_arguments(code)

      code << ")"
    end

    private

    def method
      component.name
    end

    def argument
      component.identifier
    end

    def attributes
      component.attributes
    end

    def append_positional_argument(code)
      if required_identifier?
        if argument.nil?
          raise Curly::Error, "`#{method}` requires an identifier"
        end

        code << argument.inspect
      elsif optional_identifier?
        code << argument.inspect unless argument.nil?
      elsif invalid_signature?
        raise Curly::Error, "`#{method}` is not a valid component method"
      elsif !argument.nil?
        raise Curly::Error, "`#{method}` does not take an identifier"
      end
    end

    def append_keyword_arguments(code)
      unless keyword_argument_string.empty?
        code << ", " unless argument.nil?
        code << keyword_argument_string
      end
    end

    def invalid_signature?
      positional_params = param_types.select {|type| [:req, :opt].include?(type) }
      positional_params.size > 1
    end

    def required_identifier?
      param_types.include?(:req)
    end

    def optional_identifier?
      param_types.include?(:opt)
    end

    def keyword_argument_string
      @keyword_argument_string ||= attributes.map {|name, value|
        "#{name}: #{value.inspect}"
      }.join(", ")
    end

    def validate_attributes!
      attributes.keys.each do |key|
        unless attribute_names.include?(key)
          raise Curly::Error, "`#{method}` does not allow attribute `#{key}`"
        end
      end

      required_attribute_names.each do |key|
        unless attributes.key?(key)
          raise Curly::Error, "`#{method}` is missing the required attribute `#{key}`"
        end
      end
    end

    def params
      @params ||= presenter_class.instance_method(method).parameters
    end

    def param_types
      params.map(&:first)
    end

    def attribute_names
      @attribute_names ||= params.
        select {|type, name| [:key, :keyreq].include?(type) }.
        map {|type, name| name.to_s }
    end

    def required_attribute_names
      @required_attribute_names ||= params.
        select {|type, name| type == :keyreq }.
        map {|type, name| name.to_s }
    end
  end
end
