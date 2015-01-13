require 'spec_helper'

describe Curly::Compiler do
  include CompilationSupport

  context "normal rendering" do
    let(:presenter_class) do
      Class.new(Curly::Presenter) do
        presents :list

        def title
          @list.title
        end

        def items(status: nil)
          if status
            @list.items.select {|item| item.status == status }
          else
            @list.items
          end
        end

        def companies
          "Nike, Adidas"
        end

        def numbers
          "one, two, three"
        end
      end
    end

    let(:simple_presenter_class) do
      Class.new(Curly::Presenter) do
        presents :company

        def name
          @company
        end
      end
    end

    let(:inner_presenter_class) do
      Class.new(Curly::Presenter) do
        presents :item, :item_counter
        presents :list, default: nil

        attr_reader :item_counter

        def name
          @item.name
        end

        def list_title
          @list.title
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
    let(:presenter) { presenter_class.new(context, "list" => list) }

    before do
      stub_const("ItemPresenter", inner_presenter_class)
      stub_const("PartPresenter", inner_inner_presenter_class)
    end

    it "compiles collection blocks" do
      item1 = double("item1", name: "foo")
      item2 = double("item2", name: "bar")

      list.stub(:items) { [item1, item2] }

      template = "<ul>{{*items}}<li>{{name}}</li>{{/items}}</ul>"
      expect(evaluate(template)).to eql "<ul><li>foo</li><li>bar</li></ul>"
    end

    it "allows attributes on collection blocks" do
      item1 = double("item1", name: "foo", status: "active")
      item2 = double("item2", name: "bar", status: "inactive")

      list.stub(:items) { [item1, item2] }

      template = "<ul>{{*items status=active}}<li>{{name}}</li>{{/items}}</ul>"
      expect(evaluate(template)).to eql "<ul><li>foo</li></ul>"
    end

    it "fails if the component isn't available" do
      template = "<ul>{{*doodads}}<li>{{name}}</li>{{/doodads}}</ul>"
      expect { evaluate(template) }.to raise_exception(Curly::Error)
    end

    it "fails if the component doesn't support enumeration" do
      template = "<ul>{{*numbers}}<li>{{name}}</li>{{/numbers}}</ul>"
      expect { evaluate(template) }.to raise_exception(Curly::Error)
    end

    it "works even if the component method doesn't return an Array" do
      stub_const("CompanyPresenter", simple_presenter_class)
      template = "<ul>{{*companies}}<li>{{name}}</li>{{/companies}}</ul>"
      expect(evaluate(template)).to eql "<ul><li>Nike, Adidas</li></ul>"
    end

    it "passes the index of the current item to the nested presenter" do
      item1 = double("item1")
      item2 = double("item2")

      list.stub(:items) { [item1, item2] }

      template = "<ul>{{*items}}<li>{{item_counter}}</li>{{/items}}</ul>"
      expect(evaluate(template)).to eql "<ul><li>1</li><li>2</li></ul>"
    end

    it "restores the previous scope after exiting the collection block" do
      part = double("part", identifier: "X")
      item = double("item", name: "foo", parts: [part])
      list.stub(:items) { [item] }

      template = "{{*items}}{{*parts}}{{identifier}}{{/parts}}{{name}}{{/items}}{{title}}"
      expect(evaluate(template)).to eql "XfooInventory"
    end

    it "passes the parent presenter's options to the nested presenter" do
      list.stub(:items) { [double(name: "foo"), double(name: "bar")] }

      template = "{{*items}}{{list_title}}: {{name}}. {{/items}}"
      expect(evaluate(template, list: list)).to eql "Inventory: foo. Inventory: bar. "
    end

    it "compiles nested collection blocks" do
      item1 = double("item1", name: "item1", parts: [double(identifier: "A"), double(identifier: "B")])
      item2 = double("item2", name: "item2", parts: [double(identifier: "C"), double(identifier: "D")])

      list.stub(:items) { [item1, item2] }

      template = "{{title}}: {{*items}}{{name}} - {{*parts}}{{identifier}}{{/parts}}. {{/items}}"
      expect(evaluate(template)).to eql "Inventory: item1 - AB. item2 - CD. "
    end
  end

  context "re-using assign names" do
    let(:context) { double("context") }
    let(:options) { Hash.new }
    let(:presenter) { ShowPresenter.new(context, options) }

    before do
      define_presenter "ShowPresenter" do
        presents :comment

        attr_reader :comment

        def comments
          ["yolo", "xoxo"]
        end

        def comment(&block)
          block.call("viagra!")
        end

        def form(&block)
          block.call
        end
      end

      define_presenter "CommentPresenter" do
        presents :comment
      end

      define_presenter "FormPresenter" do
        presents :comment
        attr_reader :comment
      end
    end

    it "allows re-using assign names in collection blocks" do
      options.update("comment" => "first post!")
      template = "{{*comments}}{{/comments}}{{@form}}{{comment}}{{/form}}"
      expect(evaluate(template, options)).to eql "first post!"
    end

    it "allows re-using assign names in context blocks" do
      options.update("comment" => "first post!")
      template = "{{@comment}}{{/comment}}{{@form}}{{comment}}{{/form}}"
      expect(evaluate(template, options)).to eql "first post!"
    end

  end
end
