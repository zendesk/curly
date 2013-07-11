require 'curly/scanner'
require 'curly/invalid_reference'

module Curly

  # Compiles Curly templates into executable Ruby code.
  #
  # A template must be accompanied by a presenter class. This class defines the
  # references that are valid within the template.
  #
  class Compiler
    # Compiles a Curly template to Ruby code.
    #
    # template        - The template String that should be compiled.
    # presenter_class - The presenter Class.
    #
    # Returns a String containing the Ruby code.
    def self.compile(template, presenter_class)
      new(template, presenter_class).compile
    end

    # Whether the Curly template is valid. This includes whether all
    # references are available on the presenter class.
    #
    # template        - The template String that should be validated.
    # presenter_class - The presenter Class.
    #
    # Returns true if the template is valid, false otherwise.
    def self.valid?(template, presenter_class)
      compile(template, presenter_class)

      true
    rescue InvalidReference
      false
    end

    attr_reader :template, :presenter_class

    def initialize(template, presenter_class)
      @template, @presenter_class = template, presenter_class
    end

    def compile
      if presenter_class.nil?
        raise ArgumentError, "presenter class cannot be nil"
      end

      tokens = Scanner.scan(template)

      parts = tokens.map do |type, value|
        send("compile_#{type}", value)
      end

      <<-RUBY
        buffer = ActiveSupport::SafeBuffer.new
        #{parts.join("\n")}
        buffer
      RUBY
    end

    private

    def compile_reference(reference)
      method, argument = reference.split(".", 2)

      unless presenter_class.method_available?(method.to_sym)
        raise Curly::InvalidReference.new(method.to_sym)
      end

      if presenter_class.instance_method(method).arity == 1
        # The method accepts a single argument -- pass it in.
        code = <<-RUBY
          presenter.#{method}(#{argument.inspect}) {|*args| yield(*args) }
        RUBY
      else
        code = <<-RUBY
          presenter.#{method} {|*args| yield(*args) }
        RUBY
      end

      'buffer.concat(%s)' % code.strip
    end

    def compile_text(text)
      'buffer.safe_concat(%s)' % text.inspect
    end

    def compile_comment_line(comment)
      "" # Replace the content with an empty string.
    end

    def compile_comment(comment)
      "" # Replace the content with an empty string.
    end
  end
end
