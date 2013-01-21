require 'curly/compiler'
require 'active_support/core_ext/string/output_safety'

describe Curly::Compiler do
  let :presenter_class do
    Class.new do
      def foo
        "FOO"
      end

      def high_yield
        "#{yield}, motherfucker!"
      end

      def yield_value
        "#{yield :foo}, please?"
      end

      def unicorns
        "UNICORN"
      end

      def method_available?(method)
        [:foo, :high_yield, :yield_value, :dirty].include?(method)
      end

      def self.available_methods
        public_instance_methods
      end

      private

      def method_missing(*args)
        "BAR"
      end
    end
  end

  let(:presenter) { presenter_class.new }
  let(:context) { double("context", presenter: presenter) }

  it "compiles Curly templates to Ruby code" do
    evaluate("{{foo}}").should == "FOO"
  end

  it "makes sure only public methods are called on the presenter object" do
    expect { evaluate("{{bar}}") }.to raise_exception(Curly::InvalidReference)
  end

  it "propagates yields to the caller" do
    evaluate("{{high_yield}}") { "$$$" }.should == "$$$, motherfucker!"
  end

  it "sends along arguments passed to yield" do
    evaluate("{{yield_value}}") {|v| v.upcase }.should == "FOO, please?"
  end

  it "escapes non HTML safe strings returned from the presenter" do
    presenter.stub(:dirty) { "<p>dirty</p>" }
    evaluate("{{dirty}}").should == "&lt;p&gt;dirty&lt;/p&gt;"
  end

  it "does not escape HTML safe strings returned from the presenter" do
    presenter.stub(:dirty) { "<p>dirty</p>".html_safe }
    evaluate("{{dirty}}").should == "<p>dirty</p>"
  end

  def evaluate(template)
    code = Curly::Compiler.compile(template)
    context.instance_eval(code)
  end
end
