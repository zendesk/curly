require 'rltk'

module Curly
  class HbsParser < RLTK::Parser

    production(:template) do
      clause('template_items') { |i| i }
    end

    production(:template_items) do
      clause('template_item') { |i| [i] }
      clause('template_items template_item') { |i0,i1| i0 << i1 }
    end

    production(:template_item) do
      clause('output') { |e| e }
      clause('comment') { |e| e }
      clause('expression') { |e| e }
      clause('block_expression') { |e| e }
    end

    production(:output) do
      clause('OUT') { |o| Text.new(o) }
    end

    production(:comment) do
      clause('CURLYSTART BANG COMMENT CURLYEND') { |_,_,e,_| Comment.new(e) }
    end

    production(:expression) do
      clause('CURLYSTART object CURLYEND') { |_,e,_| e }
    end

    production(:object) do
      clause('IDENT') do |e| 
        if e.include? "."
          splitted = e.split(".")
          Component.new(splitted.first, splitted[1..-1].join("."))
        else
          Component.new(e)
        end
      end
    end

    production(:block_expression) do
      clause('cond_bl_start template cond_bl_end') { |e0, e1, _| Block.new(:conditional, e0, e1) }
      clause('cond_bl_start template else template cond_bl_end') { |e0, e1, _, e2, _| Block.new(:conditional, e0, e1, e2) }

      clause('inv_cond_bl_start template inv_cond_bl_end') { |e0, e1, _| Block.new(:inverse_conditional, e0, e1) }
      clause('inv_cond_bl_start template else template inv_cond_bl_end') { |e0, e1, _, e2, _| Block.new(:inverse_conditional, e0, e1, e2) }

      clause('col_bl_start template col_bl_end') { |e0, e1, _| Block.new(:collection, e0, e1) }
      clause('col_bl_start template else template col_bl_end') { |e0, e1, _, e2, _| Block.new(:collection, e0, e1, e2) }

      clause('context_bl_start template context_bl_end') { |e0, e1, _| Block.new(:context, e0, e1) }
    end

    production(:cond_bl_start) do
      clause('CURLYSTART IF object CURLYEND') { |_,_,e,_| e }
    end

    production(:cond_bl_end) do
      clause('CURLYSTART IFCLOSE CURLYEND') { |_,_,_| }
    end

    production(:inv_cond_bl_start) do
      clause('CURLYSTART UNLESS object CURLYEND') { |_,_,e,_| e }
    end

    production(:inv_cond_bl_end) do
      clause('CURLYSTART UNLESSCLOSE CURLYEND') { |_,_,_| }
    end

    production(:col_bl_start) do
      clause('CURLYSTART EACH object CURLYEND') { |_,_,e,_| e }
    end

    production(:col_bl_end) do
      clause('CURLYSTART EACHCLOSE CURLYEND') { |_,_,_| }
    end

    production(:context_bl_start) do
      clause('CURLYSTART WITH object CURLYEND') { |_,_,e,_| e }
    end

    production(:context_bl_end) do
      clause('CURLYSTART WITHCLOSE CURLYEND') { |_,_,_| }
    end

    production(:else) do
      clause('CURLYSTART ELSE CURLYEND') { |_,_,_| }
    end

    finalize

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

      def ==(other)
        other.value == value
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

      def ==(other)
        other.value == value
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
  end
end
