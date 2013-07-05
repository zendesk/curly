require 'curly/invalid_reference'

module Curly
  class Compiler
    REFERENCE_REGEX = %r(\{\{([\w\.]+)\}\})
    COMMENT_REGEX = %r(\{\{\!\s*(.*)\s*\}\})
    COMMENT_LINE_REGEX = %r(^\s*#{COMMENT_REGEX}\s*\n)

    class << self

      # Compiles a Curly template to Ruby code.
      #
      # template - The template String that should be compiled.
      #
      # Returns a String containing the Ruby code.
      def compile(template, presenter_class)
        if presenter_class.nil?
          raise ArgumentError, "presenter class cannot be nil"
        end

        source = template.dup

        # Escape double quotes.
        source.gsub!('"', '\"')

        source.gsub!(REFERENCE_REGEX) { compile_reference($1, presenter_class) }
        source.gsub!(COMMENT_LINE_REGEX) { compile_comment_line($1) }
        source.gsub!(COMMENT_REGEX) { compile_comment($1) }

        '"%s"' % source
      end

      # Whether the Curly template is valid. This includes whether all
      # references are available on the presenter class.
      #
      # template        - The template String that should be validated.
      # presenter_class - The presenter Class.
      #
      # Returns true if the template is valid, false otherwise.
      def valid?(template, presenter_class)
        compile(template, presenter_class)

        true
      rescue InvalidReference
        false
      end

      private

      def compile_reference(reference, presenter_class)
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

        '#{ERB::Util.html_escape(%s)}' % code.strip
      end

      def compile_comment_line(comment)
        "" # Replace the content with an empty string.
      end

      def compile_comment(comment)
        "" # Replace the content with an empty string.
      end
    end
  end
end
