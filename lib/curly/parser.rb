require 'curly/incomplete_block_error'
require 'curly/incorrect_ending_error'

class Curly::Parser
  class Component
    attr_reader :name, :identifier, :attributes, :contexts

    def initialize(name, identifier = nil, attributes = {}, contexts = [])
      @name, @identifier, @attributes, @contexts = name, identifier, attributes, contexts
    end

    def to_s
      contexts.map {|c| c + ":" }.join << [name, identifier].compact.join(".")
    end

    def ==(other)
      other.name == name &&
        other.identifier == identifier &&
        other.attributes == attributes &&
        other.contexts == contexts
    end

    def type
      :component
    end
  end

  class Text
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def type
      :text
    end
  end

  class Comment
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def type
      :comment
    end
  end

  class Root
    attr_reader :nodes

    def initialize
      @nodes = []
    end

    def <<(node)
      @nodes << node
    end

    def to_s
      "<root>"
    end

    def closed_by?(component)
      false
    end
  end

  class Block
    attr_reader :type, :component, :nodes

    def initialize(type, component, nodes = [])
      @type, @component, @nodes = type, component, nodes
    end

    def closed_by?(component)
      self.component.name == component.name &&
        self.component.identifier == component.identifier &&
        self.component.contexts == component.contexts
    end

    def to_s
      component.to_s
    end

    def <<(node)
      @nodes << node
    end

    def ==(other)
      other.type == type &&
        other.component == component &&
        other.nodes == nodes
    end
  end

  def self.parse(tokens)
    new(tokens).parse
  end

  def initialize(tokens)
    @tokens = tokens
    @root = Root.new
    @stack = [@root]
  end

  def parse
    @tokens.each do |token, *args|
      send("parse_#{token}", *args)
    end

    unless @stack.size == 1
      raise Curly::IncompleteBlockError,
        "block `#{@stack.last}` is not closed"
    end

    @root.nodes
  end

  private

  def parse_text(value)
    tree << Text.new(value)
  end

  def parse_component(*args)
    component = Component.new(*args)

    # If the component is namespaced by a list of context names, open a context
    # block for each.
    component.contexts.each do |context|
      parse_context_block_start(context)
    end

    tree << component

    # Close each context block in the namespace.
    component.contexts.reverse.each do |context|
      parse_block_end(context)
    end
  end

  def parse_conditional_block_start(*args)
    parse_block(:conditional, *args)
  end

  def parse_inverse_conditional_block_start(*args)
    parse_block(:inverse_conditional, *args)
  end

  def parse_else_block_start(*args)
    block = @stack.pop

    if block.nil?
      raise Curly::Error, "An else needs to be in a block"
    end

    unless block.type == :conditional
      raise Curly::Error, "An else needs to be in a conditional block"
    end

    component = block.component

    parse_block(:inverse_conditional, *[component.name, component.identifier, component.attributes])
  end

  def parse_collection_block_start(*args)
    parse_block(:collection, *args)
  end

  def parse_context_block_start(*args)
    parse_block(:context, *args)
  end

  def parse_block(type, *args)
    component = Component.new(*args)

    component.contexts.each do |context|
      parse_context_block_start(context)
    end

    block = Block.new(type, component)
    tree << block
    @stack.push(block)
  end

  def parse_conditional_block_end(*args)
    block = @stack.pop

    unless block.type == :conditional || block.type == :inverse_conditional
      raise Curly::IncorrectEndingError,
        "block `#{block}` cannot be closed by a conditional block end"
    end
  end

  def parse_block_end(*args)
    component = Component.new(*args)
    block = @stack.pop

    unless block.closed_by?(component)
      raise Curly::IncorrectEndingError,
        "block `#{block}` cannot be closed by `#{component}`"
    end

    component.contexts.reverse.each do |context|
      parse_block_end(context)
    end
  end

  def parse_comment(comment)
    tree << Comment.new(comment)
  end

  def tree
    @stack.last
  end
end
