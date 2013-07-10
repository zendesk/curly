require 'strscan'
require 'curly/invalid_reference'

module Curly
  class Compiler
    REFERENCE_REGEX = %r(\{\{([\w\.]+)\}\})
    COMMENT_REGEX = %r(\{\{\!\s*(.*)\s*\}\})
    COMMENT_LINE_REGEX = %r(\s*#{COMMENT_REGEX}\s*\n)

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

      scanner = StringScanner.new(template)
      result = []

      result << scan_token(scanner) until scanner.eos?

      result.join(" + ")
    end

    private

    def scan_token(scanner)
      if reference = scan_reference(scanner)
        compile_reference(reference)
      elsif comment = scan_comment_line(scanner)
        compile_comment_line(comment)
      elsif comment = scan_comment(scanner)
        compile_comment(comment)
      elsif text = scan_text(scanner)
        compile_text(text)
      else
        text = scan_remainder(scanner)
        compile_text(text)
      end
    end

    def scan_reference(scanner)
      if reference = scanner.scan(REFERENCE_REGEX)
        # Return the text excluding the "{{}}"
        reference[2..-3]
      end
    end

    def scan_comment_line(scanner)
      scanner.scan(COMMENT_LINE_REGEX)
    end

    def scan_comment(scanner)
      scanner.scan(COMMENT_REGEX)
    end

    def scan_text(scanner)
      if text = scanner.scan_until(/\{\{/m)
        # Rewind the scanner until before the "{{"
        scanner.pos -= 2

        # Return the text up until "{{"
        text[0..-3]
      end
    end

    def scan_remainder(scanner)
      scanner.scan(/.+/m)
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
