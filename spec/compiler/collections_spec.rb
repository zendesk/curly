require 'spec_helper'

describe Curly::Compiler do
  include CompilationSupport

  context "normal rendering" do
    before do
      define_presenter "ItemPresenter" do
        presents :item
        delegate :name, to: :@item
      end
    end

    it "compiles collection blocks" do
      define_presenter do
        presents :items
        attr_reader :items
      end

      item1 = double("item1", name: "foo")
      item2 = double("item2", name: "bar")

      template = "<ul>{{*items}}<li>{{name}}</li>{{/items}}</ul>"
      expect(render(template, items: [item1, item2])).to eql "<ul><li>foo</li><li>bar</li></ul>"
    end

    it "allows attributes on collection blocks" do
      define_presenter do
        presents :items

        def items(status: nil)
          if status
            @items.select {|item| item.status == status }
          else
            @items
          end
        end
      end

      item1 = double("item1", name: "foo", status: "active")
      item2 = double("item2", name: "bar", status: "inactive")

      template = "<ul>{{*items status=active}}<li>{{name}}</li>{{/items}}</ul>"
      expect(render(template, items: [item1, item2])).to eql "<ul><li>foo</li></ul>"
    end

    it "fails if the component doesn't support enumeration" do
      template = "<ul>{{*numbers}}<li>{{name}}</li>{{/numbers}}</ul>"
      expect { render(template) }.to raise_exception(Curly::Error)
    end

    it "works even if the component method doesn't return an Array" do
      define_presenter do
        def companies
          "Arla"
        end
      end

      define_presenter "CompanyPresenter" do
        presents :company

        def name
          @company
        end
      end

      template = "<ul>{{*companies}}<li>{{name}}</li>{{/companies}}</ul>"
      expect(render(template)).to eql "<ul><li>Arla</li></ul>"
    end

    it "passes the index of the current item to the nested presenter" do
      define_presenter do
        presents :items
        attr_reader :items
      end

      define_presenter "ItemPresenter" do
        presents :item_counter

        def index
          @item_counter
        end
      end

      item1 = double("item1")
      item2 = double("item2")

      template = "<ul>{{*items}}<li>{{index}}</li>{{/items}}</ul>"
      expect(render(template, items: [item1, item2])).to eql "<ul><li>1</li><li>2</li></ul>"
    end

    it "restores the previous scope after exiting the collection block" do
      define_presenter do
        presents :items
        attr_reader :items

        def title
          "Inventory"
        end
      end

      define_presenter "ItemPresenter" do
        presents :item
        delegate :name, :parts, to: :@item
      end

      define_presenter "PartPresenter" do
        presents :part
        delegate :identifier, to: :@part
      end

      part = double("part", identifier: "X")
      item = double("item", name: "foo", parts: [part])

      template = "{{*items}}{{*parts}}{{identifier}}{{/parts}}{{name}}{{/items}}{{title}}"
      expect(render(template, items: [item])).to eql "XfooInventory"
    end

    it "passes the parent presenter's options to the nested presenter" do
      define_presenter do
        presents :items, :prefix
        attr_reader :items
      end

      define_presenter "ItemPresenter" do
        presents :item, :prefix
        delegate :name, to: :@item
        attr_reader :prefix
      end

      item1 = double(name: "foo")
      item2 = double(name: "bar")

      template = "{{*items}}{{prefix}}: {{name}}; {{/items}}"
      expect(render(template, prefix: "SKU", items: [item1, item2])).to eql "SKU: foo; SKU: bar; "
    end

    it "compiles nested collection blocks" do
      define_presenter do
        presents :items
        attr_reader :items
      end

      define_presenter "ItemPresenter" do
        presents :item
        delegate :name, :parts, to: :@item
      end

      define_presenter "PartPresenter" do
        presents :part
        delegate :identifier, to: :@part
      end

      item1 = double("item1", name: "item1", parts: [double(identifier: "A"), double(identifier: "B")])
      item2 = double("item2", name: "item2", parts: [double(identifier: "C"), double(identifier: "D")])

      template = "{{*items}}{{name}}: {{*parts}}{{identifier}}{{/parts}}; {{/items}}"
      expect(render(template, items: [item1, item2])).to eql "item1: AB; item2: CD; "
    end
  end

  context "re-using assign names" do
    before do
      define_presenter do
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
      options = { "comment" => "first post!" }
      template = "{{*comments}}{{/comments}}{{@form}}{{comment}}{{/form}}"
      expect(render(template, options)).to eql "first post!"
    end

    it "allows re-using assign names in context blocks" do
      options = { "comment" => "first post!" }
      template = "{{@comment}}{{/comment}}{{@form}}{{comment}}{{/form}}"
      expect(render(template, options)).to eql "first post!"
    end
  end
end
