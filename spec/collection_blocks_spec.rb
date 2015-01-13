describe "Collection block components" do
  include CompilationSupport

  before do
    define_presenter "ItemPresenter" do
      presents :item

      def name
        @item
      end
    end
  end

  example "with neither identifier nor attributes" do
    define_presenter do
      def items
        ["one", "two", "three"]
      end
    end

    render("{{*items}}<{{name}}>{{/items}}").should == "<one><two><three>"
  end

  example "with an identifier" do
    define_presenter do
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
    define_presenter do
      def items(length: "1")
        ["x"] * length.to_i
      end
    end

    render("{{*items length=3}}<{{name}}>{{/items}}").should == "<x><x><x>"
    render("{{*items}}<{{name}}>{{/items}}").should == "<x>"
  end

  example "with nested collection blocks" do
    define_presenter do
      def items
        [{ parts: [1, 2] }, { parts: [3, 4] }]
      end
    end

    define_presenter "ItemPresenter" do
      presents :item

      def parts
        @item[:parts]
      end
    end

    define_presenter "PartPresenter" do
      presents :part

      def number
        @part
      end
    end

    render("{{*items}}<{{*parts}}[{{number}}]{{/parts}}>{{/items}}").should == "<[1][2]><[3][4]>"
  end
end
