describe Curly::Compiler do
  include CompilationSupport

  it "compiles context blocks" do
    define_presenter do
      def form(&block)
        "<form>".html_safe + block.call("yo") + "</form>".html_safe
      end
    end

    define_presenter "FormPresenter" do
      presents :form

      def text_field(&block)
        block.call(@form)
      end
    end

    define_presenter "TextFieldPresenter" do
      presents :text_field

      def field
        %(<input type="text" value="#{@text_field.upcase}">).html_safe
      end

      def value?
        true
      end
    end

    expect(render('{{@form}}{{@text_field}}{{field}}{{/text_field}}{{/form}}')).to eq '<form><input type="text" value="YO"></form>'
  end

  it "compiles using the right presenter" do
    define_presenter "Layouts::SomePresenter" do

      def contents(&block)
        block.call("hello, world")
      end
    end

    define_presenter "Layouts::SomePresenter::ContentsPresenter" do
      presents :contents

      def contents
        @contents
      end
    end

    expect(render("foo: {{@contents}}{{contents}}{{/contents}}", presenter: "Layouts::SomePresenter")).to eq 'foo: hello, world'
  end

  it "fails if the component is not a context block" do
    define_presenter do
      def form
      end
    end

    expect {
      render('{{@form}}{{/form}}')
    }.to raise_exception(Curly::Error)
  end

  it "fails if the component doesn't match a presenter class" do
    define_presenter do
      def dust(&block)
      end
    end

    expect {
      render('{{@dust}}{{/dust}}')
    }.to raise_exception(Curly::Error)
  end

  it "fails if the component is not a context block" do
    expect { render('{{@invalid}}yo{{/invalid}}') }.to raise_exception(Curly::Error)
  end

  it "compiles shorthand context components" do
    define_presenter do
      def tree(&block)
        yield
      end
    end

    define_presenter "TreePresenter" do
      def branch(&block)
        yield
      end
    end

    define_presenter "BranchPresenter" do
      def leaf
        "leaf"
      end
    end

    expect(render('{{tree:branch:leaf}}')).to eq "leaf"
  end

  it "requires shorthand blocks to be closed with the same set of namespaces" do
    expect do
      render('{{#tree:branch}}{{/branch}}{{/tree}}')
    end.to raise_exception(Curly::IncorrectEndingError)
  end
end
