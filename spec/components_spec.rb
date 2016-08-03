describe "Components" do
  include CompilationSupport

  example "with neither identifier nor attributes" do
    define_presenter do
      def title
        "A Clockwork Orange"
      end
    end

    expect(render("{{title}}")).to eq "A Clockwork Orange"
  end

  example "with an identifier" do
    define_presenter do
      def reverse(str)
        str.reverse
      end
    end

    expect(render("{{reverse.123}}")).to eq "321"
  end

  example "with attributes" do
    define_presenter do
      def double(number:)
        number.to_i * 2
      end
    end

    expect(render("{{double number=3}}")).to eq "6"
  end

  example "with both identifier and attributes" do
    define_presenter do
      def a(href:, title:)
        content_tag :a, nil, href: href, title: title
      end
    end

    expect(render(%({{a href="/welcome.html" title="Welcome!"}}))).to eq %(<a href="/welcome.html" title="Welcome!"></a>)
  end
end
