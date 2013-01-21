module Curly
  class InvalidReference < StandardError
  end

  class Compiler
    REFERENCE_REGEX = %r(\{\{(\w+)\}\})

    attr_reader :template

    def initialize(template)
      @template = template
    end

    def self.compile(template)
      new(template).compile
    end

    def compile
      source = template.inspect
      source.gsub!(REFERENCE_REGEX) { compile_reference($1) }

      source
    end

    private

    def compile_reference(reference)
      (<<-RUBY).strip
      \#{
        if presenter.method_available?(:#{reference})
          result = presenter.#{reference} {|*args| yield(*args) }
          ERB::Util.html_escape(result)
        else
          raise Curly::InvalidReference, "invalid reference `{{#{reference}}}'"
        end
      }
      RUBY
    end
  end
end
