require 'curly/scanner'
require 'curly/invalid_reference'

module Curly
  class Compiler
    # Compiles a Curly template to Ruby code.
    #
    # template - The template String that should be compiled.
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

      scanner = Scanner.new(template)
      result = []

      result << scan_token(scanner) until scanner.eos?

      result.join(" + ")
    end

    private

    def scan_token(scanner)
      if reference = scanner.scan_reference
        compile_reference(reference)
      elsif comment = scanner.scan_comment_line
        compile_comment_line(comment)
      elsif comment = scanner.scan_comment
        compile_comment(comment)
      elsif text = scanner.scan_text
        compile_text(text)
      else
        text = scanner.scan_remainder
        compile_text(text)
      end
    end

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

      'ERB::Util.html_escape(%s)' % code.strip
    end

    def compile_text(text)
      text.inspect
    end

    def compile_comment_line(comment)
      "''" # Replace the content with an empty string.
    end

    def compile_comment(comment)
      "''" # Replace the content with an empty string.
    end
  end
end
