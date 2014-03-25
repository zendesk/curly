require 'curly/scanner'
require 'curly/reference_compiler'
require 'curly/error'
require 'curly/invalid_reference'
require 'curly/incorrect_ending_error'
require 'curly/incomplete_block_error'

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
    # Raises InvalidReference if the template contains a reference that is not
    #   allowed.
    # Raises IncorrectEndingError if a conditional block is not ended in the
    #   correct order - the most recent block must be ended first.
    # Raises IncompleteBlockError if a block is not completed.
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
    rescue Error
      false
    end

    attr_reader :template

    def initialize(template, presenter_class)
      @template = template
      @presenter_classes = [presenter_class]
    end

    def compile
      if presenter_class.nil?
        raise ArgumentError, "presenter class cannot be nil"
      end

      tokens = Scanner.scan(template)

      @blocks = []

      parts = tokens.map do |type, value|
        send("compile_#{type}", value)
      end

      if @blocks.any?
        raise IncompleteBlockError.new(@blocks.pop)
      end

      <<-RUBY
        buffer = ActiveSupport::SafeBuffer.new
        presenters = []
        #{parts.join("\n")}
        buffer
      RUBY
    end

    private

    def presenter_class
      @presenter_classes.last
    end

    def compile_conditional_block_start(reference)
      compile_conditional_block "if", reference
    end

    def compile_inverse_conditional_block_start(reference)
      compile_conditional_block "unless", reference
    end

    def compile_collection_block_start(reference)
      unless presenter_class.method_available?(reference)
        raise Curly::InvalidReference.new(reference)
      end

      as = reference.singularize
      counter = "#{as}_counter"

      begin
        nested_presenter_name = "#{as.camelcase}Presenter"
        item_presenter_class = presenter_class.const_get(nested_presenter_name)
      rescue NameError
        raise Curly::Error,
          "cannot enumerate `#{reference}`, no matching presenter #{nested_presenter_name}"
      end

      @blocks.push(reference)
      @presenter_classes.push(item_presenter_class)

      <<-RUBY
        presenters << presenter
        items = Array(presenter.#{reference})
        items.each_with_index do |item, index|
          item_options = options.merge(:#{as} => item, :#{counter} => index + 1)
          presenter = #{item_presenter_class}.new(self, item_options)
      RUBY
    end

    def compile_conditional_block(keyword, reference)
      method_call = ReferenceCompiler.compile_conditional(presenter_class, reference)

      @blocks.push(reference)

      <<-RUBY
        #{keyword} #{method_call}
      RUBY
    end

    def compile_conditional_block_end(reference)
      validate_block_end(reference)

      <<-RUBY
        end
      RUBY
    end

    def compile_collection_block_end(reference)
      @presenter_classes.pop
      validate_block_end(reference)

      <<-RUBY
        end
        presenter = presenters.pop
      RUBY
    end

    def compile_reference(reference)
      method_call = ReferenceCompiler.compile_reference(presenter_class, reference)
      code = "#{method_call} {|*args| yield(*args) }"

      "buffer.concat(#{code.strip}.to_s)"
    end

    def compile_text(text)
      "buffer.safe_concat(#{text.inspect})"
    end

    def compile_comment(comment)
      "" # Replace the content with an empty string.
    end

    def validate_block_end(reference)
      last_block = @blocks.pop

      unless last_block == reference
        raise Curly::IncorrectEndingError.new(reference, last_block)
      end
    end
  end
end
