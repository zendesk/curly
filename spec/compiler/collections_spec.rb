require 'spec_helper'

describe Curly::Compiler do
  include CompilationSupport

  let(:presenter_class) do
    Class.new(Curly::Presenter) do
      presents :list

      def title
        @list.title
      end

      def items
        @list.items
      end
    end
  end

  let(:inner_presenter_class) do
    Class.new(Curly::Presenter) do
      presents :item

      def name
        @item.name
      end

      def parts
        @item.parts
      end
    end
  end

  let(:inner_inner_presenter_class) do
    Class.new(Curly::Presenter) do
      presents :part

      def identifier
        @part.identifier
      end
    end
  end

  let(:list) { double("list", title: "Inventory") }
  let(:context) { double("context") }
  let(:presenter) { presenter_class.new(context, list: list) }

  before do
    stub_const("ItemPresenter", inner_presenter_class)
    stub_const("PartPresenter", inner_inner_presenter_class)
  end

  it "compiles collection blocks" do
    item1 = double("item1", name: "foo")
    item2 = double("item2", name: "bar")

    list.stub(:items) { [item1, item2] }

    template = "<ul>{{#items}}<li>{{name}}</li>{{/items}}</ul>"
    evaluate(template).should == "<ul><li>foo</li><li>bar</li></ul>"
  end

  it "restores the previous scope after exiting the collection block" do
    part = double("part", identifier: "X")
    item = double("item", name: "foo", parts: [part])
    list.stub(:items) { [item] }

    template = "{{#items}}{{#parts}}{{identifier}}{{/parts}}{{name}}{{/items}}{{title}}"
    evaluate(template).should == "XfooInventory"
  end

  it "compiles nested collection blocks" do
    item1 = double("item1", name: "item1", parts: [double(identifier: "A"), double(identifier: "B")])
    item2 = double("item2", name: "item2", parts: [double(identifier: "C"), double(identifier: "D")])

    list.stub(:items) { [item1, item2] }

    template = "{{title}}: {{#items}}{{name}} - {{#parts}}{{identifier}}{{/parts}}. {{/items}}"
    evaluate(template).should == "Inventory: item1 - AB. item2 - CD. "
  end
end
