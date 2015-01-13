require 'spec_helper'

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
    end

    render('{{@form}}{{@text_field}}{{field}}{{/text_field}}{{/form}}').should == '<form><input type="text" value="YO"></form>'
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
end
