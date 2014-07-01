require 'curly/scanner'
require 'curly/component_compiler'
require 'curly/component_parser'
require 'curly/error'
require 'curly/invalid_component'
require 'curly/incorrect_ending_error'
require 'curly/incomplete_block_error'

module Curly

  # Compiles Curly templates into executable Ruby code.
  #
  # A template must be accompanied by a presenter class. This class defines the
  # components that are valid within the template.
  #
  class Compiler
    # Compiles a Curly template to Ruby code.
    #
    # template        - The template String that should be compiled.
    # presenter_class - The presenter Class.
    #
    # Raises InvalidComponent if the template contains a component that is not
    #   allowed.
    # Raises IncorrectEndingError if a conditional block is not ended in the
    #   correct order - the most recent block must be ended first.
    # Raises IncompleteBlockError if a block is not completed.
    # Returns a String containing the Ruby code.
    def self.compile(template, presenter_class)
      new(template, presenter_class).compile
    end

    # Whether the Curly template is valid. This includes whether all
    # components are available on the presenter class.
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

    def compile_conditional_block_start(component)
      compile_conditional_block "if", component
    end

    def compile_inverse_conditional_block_start(component)
      compile_conditional_block "unless", component
    end

    def compile_collection_block_start(component)
      name, identifier, attributes = ComponentParser.parse(component)
      method_call = ComponentCompiler.compile_component(presenter_class, name, identifier, attributes)

      as = name.singularize
      counter = "#{as}_counter"

      begin
        item_presenter_class = presenter_class.presenter_for_name(as)
      rescue NameError
        raise Curly::Error,
          "cannot enumerate `#{component}`, could not find matching presenter class"
      end

      push_block(name, identifier)
      @presenter_classes.push(item_presenter_class)

      <<-RUBY
        presenters << presenter
        items = Array(#{method_call})
        items.each_with_index do |item, index|
          item_options = options.merge(:#{as} => item, :#{counter} => index + 1)
          presenter = #{item_presenter_class}.new(self, item_options)
      RUBY
    end

    def compile_conditional_block(keyword, component)
      name, identifier, attributes = ComponentParser.parse(component)
      method_call = ComponentCompiler.compile_conditional(presenter_class, name, identifier, attributes)

      push_block(name, identifier)

      <<-RUBY
        #{keyword} #{method_call}
      RUBY
    end

    def compile_conditional_block_end(component)
      validate_block_end(component)

      <<-RUBY
        end
      RUBY
    end

    def compile_collection_block_end(component)
      @presenter_classes.pop
      validate_block_end(component)

      <<-RUBY
        end
        presenter = presenters.pop
      RUBY
    end

    def compile_component(component)
      name, identifier, attributes = ComponentParser.parse(component)
      method_call = ComponentCompiler.compile_component(presenter_class, name, identifier, attributes)
      code = "#{method_call} {|*args| yield(*args) }"

      "buffer.concat(#{code.strip}.to_s)"
    end

    def compile_text(text)
      "buffer.safe_concat(#{text.inspect})"
    end

    def compile_comment(comment)
      "" # Replace the content with an empty string.
    end

    def validate_block_end(component)
      name, identifier, attributes = ComponentParser.parse(component)
      last_block = @blocks.pop

      if last_block.nil?
        raise Curly::Error, "block ending not expected"
      end

      unless last_block == [name, identifier]
        raise Curly::IncorrectEndingError.new([name, identifier], last_block)
      end
    end

    def push_block(name, identifier)
      @blocks.push([name, identifier])
    end
  end
end
