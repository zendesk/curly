require 'spec_helper'

describe "Components" do
  example "with neither identifier nor attributes" do
    presenter do
      def title
        "A Clockwork Orange"
      end
    end

    render("{{title}}").should == "A Clockwork Orange"
  end

  example "with an identifier" do
    presenter do
      def reverse(str)
        str.reverse
      end
    end

    render("{{reverse.123}}").should == "321"
  end

  example "with attributes" do
    presenter do
      def double(number:)
        number.to_i * 2
      end
    end

    render("{{double number=3}}").should == "6"
  end

  example "with both identifier and attributes" do
    presenter do
      def a(href:, title:)
        content_tag :a, nil, href: href, title: title
      end
    end

    render(%({{a href="/welcome.html" title="Welcome!"}})).should == %(<a href="/welcome.html" title="Welcome!"></a>)
  end

  def presenter(&block)
    @presenter = block
  end

  def render(source)
    stub_const("TestPresenter", Class.new(Curly::Presenter, &@presenter))
    identifier = "test"
    handler = Curly::TemplateHandler
    details = { virtual_path: 'test' }
    template = ActionView::Template.new(source, identifier, handler, details)
    locals = {}
    view = ActionView::Base.new

    template.render(view, locals)
  end
end
