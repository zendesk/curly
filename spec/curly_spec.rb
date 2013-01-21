require 'spec_helper'
require 'active_support/core_ext/string/output_safety'
require 'curly'

describe Curly do
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

  describe ".valid?" do
    it "validates a template with a subset of the Curly components" do
      valid_template = "Hello"
      Curly.valid?(valid_template, presenter_class).should be_true
    end

    it "validates a template with all of the Curly components" do
      valid_template = "Hello {{foo}} world!"
      Curly.valid?(valid_template, presenter_class).should be_true
    end

    it "doesn't validate a template with non-existing Curly components" do
      invalid_template = "Hello {{foo}} world! What's {{bar}} up?"
      Curly.valid?(invalid_template, presenter_class).should be_false
    end
  end

  def evaluate(template)
    code = Curly.compile(template)
    context.instance_eval(code)
  end
end
