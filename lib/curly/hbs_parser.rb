require 'rltk'

module Curly
  class HbsParser < RLTK::Parser
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

    production(:output) do
      clause('OUT') { |t| Text.new(t) }
    end

    production(:expression) do
      clause('EXPRST object EXPRE') { |_,e,_| e }
    end

    production(:object) do
      clause('IDENT') { |e| Component.new(e) }
    end

    production(:block_expression) do
      clause('cond_bl_start template cond_bl_end') { |e0, e1, _| Block.new(:conditional, e0, e1) }
      clause('cond_bl_start template else template cond_bl_end') { |e0, e1, _, e2, _| Block.new(:conditional, e0, e1, e2) }

      clause('inv_cond_bl_start template inv_cond_bl_end') { |e0, e1, _| Block.new(:inverse_conditional, e0, e1) }
      clause('inv_cond_bl_start template else template inv_cond_bl_end') { |e0, e1, _, e2, _| Block.new(:inverse_conditional, e0, e1, e2) }

      clause('col_bl_start template col_bl_end') { |e0, e1, _| Block.new(:collection, e0, e1) }
      clause('col_bl_start template else template col_bl_end') { |e0, e1, _, e2, _| Block.new(:collection, e0, e1, e2) }
    end

    production(:cond_bl_start) do
      clause('EXPRST IF WHITE IDENT EXPRE') { |_,_,_,e,_| e }
    end

    production(:cond_bl_end) do
      clause('EXPRST IFCLOSE EXPRE') { |_,_,_| }
    end

    production(:inv_cond_bl_start) do
      clause('EXPRST UNLESS WHITE IDENT EXPRE') { |_,_,_,e,_| e }
    end

    production(:inv_cond_bl_end) do
      clause('EXPRST UNLESSCLOSE EXPRE') { |_,_,_| }
    end

    production(:col_bl_start) do
      clause('EXPRST EACH IDENT EXPRE') { |_,_,e,_| e }
    end

    production(:col_bl_end) do
      clause('EXPRST EACHCLOSE EXPRE') { |_,_,_| }
    end

    production(:else) do
      clause('EXPRST ELSE EXPRE') { |_,_,_| }
    end

    finalize
  end
end
