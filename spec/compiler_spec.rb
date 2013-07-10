require 'spec_helper'

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

      def dirty
        nil
      end

      def parameterized(value)
        value
      end

      def self.method_available?(method)
        [:foo, :parameterized, :high_yield, :yield_value, :dirty].include?(method)
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

  describe ".compile" do
    it "compiles Curly templates to Ruby code" do
      evaluate("{{foo}}").should == "FOO"
    end

    it "passes on an optional reference parameter to the presenter method" do
      evaluate("{{parameterized.foo.bar}}").should == "foo.bar"
    end

    it "passes an empty string to methods that take a parameter when none is provided" do
      evaluate("{{parameterized}}").should == ""
    end

    it "raises ArgumentError if the presenter class is nil" do
      expect do
        Curly::Compiler.compile("foo", nil)
      end.to raise_exception(ArgumentError)
    end

    it "makes sure only public methods are called on the presenter object" do
      expect { evaluate("{{bar}}") }.to raise_exception(Curly::InvalidReference)
    end

    it "includes the invalid reference when failing to compile" do
      begin
        evaluate("{{bar}}")
        fail
      rescue Curly::InvalidReference => e
        e.reference.should == :bar
      end
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

    it "removes comments from the output" do
      evaluate("HELO{{! I'm a comment, yo }}WORLD").should == "HELOWORLD"
    end

    it "removes comment lines from the output" do
      evaluate(<<-CURLY.strip_heredoc).should == "HELO\nWORLD\n"
        HELO
        {{! I'm a comment }}
        WORLD
      CURLY
    end
  end

  describe ".valid?" do
    it "returns true if only available methods are referenced" do
      validate("Hello, {{foo}}!").should == true
    end

    it "returns false if a missing method is referenced" do
      validate("Hello, {{i_am_missing}}").should == false
    end

    it "returns false if an unavailable method is referenced" do
      presenter_class.stub(:available_methods) { [:foo] }
      validate("Hello, {{inspect}}").should == false
    end

    def validate(template)
      Curly.valid?(template, presenter_class)
    end
  end

  def evaluate(template, &block)
    code = Curly::Compiler.compile(template, presenter_class)
    context = double("context", presenter: presenter)

    context.instance_eval(<<-RUBY)
      def self.render
        #{code}
      end
    RUBY

    context.render(&block)
  end
end
