describe "Conditional block components" do
  include CompilationSupport

  example "with neither identifier nor attributes" do
    define_presenter do
      def high?
        true
      end

      def low?
        false
      end
    end

    expect(render("{{#high?}}yup{{/high?}}")).to eq "yup"
    expect(render("{{#low?}}nah{{/low?}}")).to eq ""
  end

  example "with an identifier" do
    define_presenter do
      def even?(number)
        number.to_i % 2 == 0
      end
    end

    expect(render("{{#even.42?}}even{{/even.42?}}")).to eq "even"
    expect(render("{{#even.13?}}even{{/even.13?}}")).to eq ""
  end

  example "with attributes" do
    define_presenter do
      def square?(width:, height:)
        width.to_i == height.to_i
      end
    end

    expect(render("{{#square? width=2 height=2}}square{{/square?}}")).to eq "square"
    expect(render("{{#square? width=3 height=2}}square{{/square?}}")).to eq ""
  end
end
