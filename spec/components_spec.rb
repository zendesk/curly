require 'spec_helper'

describe "Components" do
  include CompilationSupport

  example "with neither identifier nor attributes" do
    define_presenter do
      def title
        "A Clockwork Orange"
      end
    end

    render("{{title}}").should == "A Clockwork Orange"
  end

  example "with an identifier" do
    define_presenter do
      def reverse(str)
        str.reverse
      end
    end

    render("{{reverse.123}}").should == "321"
  end

  example "with attributes" do
    define_presenter do
      def double(number:)
        number.to_i * 2
      end
    end

    render("{{double number=3}}").should == "6"
  end

  example "with both identifier and attributes" do
    define_presenter do
      def a(href:, title:)
        content_tag :a, nil, href: href, title: title
      end
    end

    render(%({{a href="/welcome.html" title="Welcome!"}})).should == %(<a href="/welcome.html" title="Welcome!"></a>)
  end
end
