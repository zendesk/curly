require 'spec_helper'

describe "Collection block components" do
  include RenderingSupport

  before do
    item_presenter do
      presents :item

      def name
        @item
      end
    end
  end

  example "with neither identifier nor attributes" do
    presenter do
      def items
        ["one", "two", "three"]
      end
    end

    render("{{*items}}<{{name}}>{{/items}}").should == "<one><two><three>"
  end

  example "with an identifier" do
    presenter do
      def items(filter = nil)
        if filter == "even"
          ["two"]
        elsif filter == "odd"
          ["one", "three"]
        else
          ["one", "two", "three"]
        end
      end
    end

    render("{{*items.even}}<{{name}}>{{/items.even}}").should == "<two>"
    render("{{*items.odd}}<{{name}}>{{/items.odd}}").should == "<one><three>"
    render("{{*items}}<{{name}}>{{/items}}").should == "<one><two><three>"
  end

  example "with attributes" do
    presenter do
      def items(length: "1")
        ["x"] * length.to_i
      end
    end

    render("{{*items length=3}}<{{name}}>{{/items}}").should == "<x><x><x>"
    render("{{*items}}<{{name}}>{{/items}}").should == "<x>"
  end

  def item_presenter(&block)
    stub_const("ItemPresenter", Class.new(Curly::Presenter, &block))
  end
end
