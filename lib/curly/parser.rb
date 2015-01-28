require 'curly/incomplete_block_error'
require 'curly/incorrect_ending_error'

class Curly::Parser
  class Component
    attr_reader :name, :identifier, :attributes

    def initialize(name, identifier = nil, attributes = {})
      @name, @identifier, @attributes = name, identifier, attributes
    end

    def to_s
      [name, identifier].compact.join(".")
    end

    def ==(other)
      other.name == name &&
        other.identifier == identifier &&
        other.attributes == attributes
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
    attr_reader :type, :component, :nodes, :inverse_nodes

    def initialize(type, component, nodes = [], inverse_nodes = [])
      @type, @component, @nodes, @inverse_nodes = type, component, nodes, inverse_nodes

      @mode = :normal
    end

    def closed_by?(component)
      self.component.name == component.name &&
        self.component.identifier == component.identifier
    end

    def to_s
      component.to_s
    end

    def <<(node)
      if @mode == :inverse
        @inverse_nodes << node
      else
        @nodes << node
      end
    end

    def inverse!
      @mode = :inverse
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
    tree << Component.new(*args)
  end

  def parse_conditional_block_start(*args)
    parse_block(:conditional, *args)
  end

  def parse_inverse_conditional_block_start(*args)
    parse_block(:inverse_conditional, *args)
  end

  def parse_else_block_start(*args)
    block = @stack.last

    if block.nil? || ![:conditional, :inverse_conditional, :collection].include?(block.type)
      raise Curly::Error, "An else needs to be in a proper block"
    end

    block.inverse!
  end

  def parse_collection_block_start(*args)
    parse_block(:collection, *args)
  end

  def parse_context_block_start(*args)
    parse_block(:context, *args)
  end

  def parse_block(type, *args)
    component = Component.new(*args)
    block = Block.new(type, component)
    tree << block
    @stack.push(block)
  end

  def parse_conditional_block_end(*args)
    block = @stack.pop

    unless block.type == :conditional
      raise Curly::IncorrectEndingError,
        "block `#{block}` cannot be closed by a conditional block end"
    end
  end

  def parse_inverse_conditional_block_end(*args)
    block = @stack.pop

    unless block.type == :inverse_conditional
      raise Curly::IncorrectEndingError,
        "block `#{block}` cannot be closed by a inverse conditional block end"
    end
  end

  def parse_collection_block_end(*args)
    block = @stack.pop

    unless block.type == :collection
      raise Curly::IncorrectEndingError,
        "block `#{block}` cannot be closed by a collection block end"
    end
  end

  def parse_block_end(*args)
    component = Component.new(*args)
    block = @stack.pop

    unless block.closed_by?(component)
      raise Curly::IncorrectEndingError,
        "block `#{block}` cannot be closed by `#{component}`"
    end
  end

  def parse_comment(comment)
    tree << Comment.new(comment)
  end

  def tree
    @stack.last
  end
end
