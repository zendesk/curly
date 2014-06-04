require 'spec_helper'

describe Curly::ReferenceCompiler do
  let(:presenter_class) do
    Class.new do
      def title
        "Welcome!"
      end

      def i18n(key)
        "Welcome to our lovely place!"
      end

      def self.method_available?(name)
        true
      end
    end
  end

  it "compiles parameterized references" do
    evaluate("{{i18n.home.welcome}}").should == "Welcome to our lovely place!"
  end

  it "fails when a parameterized reference is missing a parameter" do
    expect { evaluate("{{i18n}}") }.to raise_exception(Curly::Error)
  end

  it "fails when a non-parameterized reference is passed a parameter" do
    expect { evaluate("{{title.rugby}}") }.to raise_exception(Curly::Error)
  end

  def evaluate(template, &block)
    code = Curly::Compiler.compile(template, presenter_class)
    presenter = presenter_class.new
    context = double("context", presenter: presenter)

    context.instance_eval(<<-RUBY)
      def self.render
        #{code}
      end
    RUBY

    context.render(&block)
  end
end
