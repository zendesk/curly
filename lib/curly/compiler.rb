require 'curly/scanner'
require 'curly/parser'
require 'curly/component_compiler'
require 'curly/error'
require 'curly/invalid_component'

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
      if presenter_class.nil?
        raise ArgumentError, "presenter class cannot be nil"
      end

      tokens = Scanner.scan(template)
      nodes = Parser.parse(tokens)

      compiler = new(presenter_class)
      compiler.compile(nodes)
      compiler.code
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

    def initialize(presenter_class)
      @presenter_classes = [presenter_class]
      @parts = []
    end

    def compile(nodes)
      nodes.each do |node|
        send("compile_#{node.type}", node)
      end
    end

    def code
      <<-RUBY
        buffer = ActiveSupport::SafeBuffer.new
        buffers = []
        presenters = []
        options_stack = []
        #{@parts.join("\n")}
        buffer
      RUBY
    end

    private

    def presenter_class
      @presenter_classes.last
    end

    def compile_conditional(block)
      compile_conditional_block("if", block)
    end

    def compile_inverse_conditional(block)
      compile_conditional_block("unless", block)
    end

    def compile_collection(block)
      component = block.component
      method_call = ComponentCompiler.compile(presenter_class, component)

      name = component.name.singularize
      counter = "#{name}_counter"

      begin
        item_presenter_class = presenter_class.presenter_for_name(name)
      rescue NameError
        raise Curly::Error,
          "cannot enumerate `#{name}`, could not find matching presenter class"
      end

      output <<-RUBY
        presenters << presenter
        options_stack << options
        items = Array(#{method_call})
        items.each_with_index do |item, index|
          options = options.merge("#{name}" => item, "#{counter}" => index + 1)
          presenter = #{item_presenter_class}.new(self, options)
      RUBY

      @presenter_classes.push(item_presenter_class)
      compile(block.nodes)
      @presenter_classes.pop

      output <<-RUBY
        end
        options = options_stack.pop
        presenter = presenters.pop
      RUBY
    end

    def compile_conditional_block(keyword, block)
      component = block.component
      method_call = ComponentCompiler.compile(presenter_class, component)

      unless component.name.end_with?("?")
        raise Curly::Error, "conditional components must end with `?`"
      end

      output <<-RUBY
        #{keyword} #{method_call}
      RUBY

      compile(block.nodes)

      if block.inverse_nodes.any?
        output <<-RUBY
          else
        RUBY

        compile(block.inverse_nodes)
      end

      output <<-RUBY
        end
      RUBY
    end

    def compile_context(block)
      component = block.component
      method_call = ComponentCompiler.compile(presenter_class, component, type: block.type)

      name = component.name

      begin
        item_presenter_class = presenter_class.presenter_for_name(name)
      rescue NameError
        raise Curly::Error,
          "cannot use context `#{name}`, could not find matching presenter class"
      end

      output <<-RUBY
        options_stack << options
        presenters << presenter
        buffers << buffer
        buffer << #{method_call} do |item|
          options = options.merge("#{name}" => item)
          buffer = ActiveSupport::SafeBuffer.new
          presenter = #{item_presenter_class}.new(self, options)
      RUBY

      @presenter_classes.push(item_presenter_class)
      compile(block.nodes)
      @presenter_classes.pop

      output <<-RUBY
          buffer
        end
        buffer = buffers.pop
        presenter = presenters.pop
        options = options_stack.pop
      RUBY
    end

    def compile_component(component)
      method_call = ComponentCompiler.compile(presenter_class, component)
      code = "#{method_call} {|*args| yield(*args) }"

      output "buffer.concat(#{code.strip}.to_s)"
    end

    def compile_text(text)
      output "buffer.safe_concat(#{text.value.inspect})"
    end

    def compile_comment(comment)
      # Do nothing.
    end

    def output(code)
      @parts << code
    end
  end
end
