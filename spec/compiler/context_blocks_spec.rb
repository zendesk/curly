require 'spec_helper'

describe Curly::Compiler do
  include CompilationSupport

  let(:presenter_class) do
    Class.new(Curly::Presenter) do
      def form(&block)
        "<form>".html_safe + block.call("yo") + "</form>".html_safe
      end
    end
  end

  let(:context_presenter_class) do
    Class.new(Curly::Presenter) do
      presents :form

      def text
        @form.upcase
      end
    end
  end

  let(:context) { double("context") }
  let(:presenter) { presenter_class.new(context, {}) }

  before do
    stub_const("FormPresenter", context_presenter_class)
  end

  it "compiles context blocks" do
    evaluate('{{@form}}{{text}}{{/form}}').should == '<form>YO</form>'
  end
end
