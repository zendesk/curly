require 'spec_helper'

describe Curly::Compiler do
  include CompilationSupport

  let(:presenter_class) do
    Class.new(Curly::Presenter) do
      def form(&block)
        "<form>".html_safe + block.call("yo") + "</form>".html_safe
      end

      def invalid
        "uh oh!"
      end
    end
  end

  let(:context_presenter_class) do
    Class.new(Curly::Presenter) do
      presents :form

      def text_field(&block)
        block.call(@form)
      end
    end
  end

  let(:inner_context_presenter_class) do
    Class.new(Curly::Presenter) do
      presents :text_field

      def field
        %(<input type="text" value="#{@text_field.upcase}">).html_safe
      end
    end
  end

  let(:context) { double("context") }
  let(:presenter) { presenter_class.new(context, {}) }

  before do
    stub_const("FormPresenter", context_presenter_class)
    stub_const("TextFieldPresenter", inner_context_presenter_class)
  end

  it "compiles context blocks" do
    evaluate('{{@form}}{{@text_field}}{{field}}{{/text_field}}{{/form}}').should == '<form><input type="text" value="YO"></form>'
  end

  it "fails if the component is not a context block" do
    expect { evaluate('{{@invalid}}yo{{/invalid}}') }.to raise_exception(Curly::Error)
  end
end
