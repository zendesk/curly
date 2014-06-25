require 'spec_helper'

describe Curly::Compiler do
  include CompilationSupport

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

      def hello?(value)
        value == "world"
      end

      def unicorns
        "UNICORN"
      end

      def dirty
        nil
      end

      def square?(width:, height:)
        width.to_i == height.to_i
      end

      def false?
        false
      end

      def true?
        true
      end

      def self.component_available?(method)
        %w[foo high_yield yield_value dirty false? true? hello? square?].include?(method)
      end

      def self.available_components
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

    it "raises ArgumentError if the presenter class is nil" do
      expect do
        Curly::Compiler.compile("foo", nil)
      end.to raise_exception(ArgumentError)
    end

    it "makes sure only public methods are called on the presenter object" do
      expect { evaluate("{{bar}}") }.to raise_exception(Curly::InvalidComponent)
    end

    it "includes the invalid component when failing to compile" do
      begin
        evaluate("{{bar}}")
        fail
      rescue Curly::InvalidComponent => e
        e.component.should == "bar"
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

    it "does not escape HTML in the template itself" do
      evaluate("<div>").should == "<div>"
    end

    it "treats all values returned from the presenter as strings" do
      presenter.stub(:foo) { 42 }
      evaluate("{{foo}}").should == "42"
    end

    it "removes comments from the output" do
      evaluate("HELO{{! I'm a comment, yo }}WORLD").should == "HELOWORLD"
    end

    it "removes text in false blocks" do
      evaluate("test{{#false?}}bar{{/false?}}").should == "test"
    end

    it "keeps text in true blocks" do
      evaluate("test{{#true?}}bar{{/true?}}").should == "testbar"
    end

    it "removes text in inverse true blocks" do
      evaluate("test{{^true?}}bar{{/true?}}").should == "test"
    end

    it "keeps kext in inverse false blocks" do
      evaluate("test{{^false?}}bar{{/false?}}").should == "testbar"
    end

    it "passes an argument to blocks" do
      evaluate("{{#hello.world?}}foo{{/hello.world?}}{{#hello.foo?}}bar{{/hello.foo?}}").should == "foo"
    end

    it "passes attributes to blocks" do
      evaluate("{{#square? width=2 height=2}}yeah!{{/square?}}").should == "yeah!"
    end

    it "gives an error on mismatching blocks" do
      expect do
        evaluate("test{{#false?}}bar{{/true?}}")
      end.to raise_exception(Curly::IncorrectEndingError)
    end

    it "gives an error on incomplete blocks" do
      expect do
        evaluate("test{{#false?}}bar")
      end.to raise_exception(Curly::IncompleteBlockError)
    end

    it "gives an error on mismatching block ends" do
      expect do
        evaluate("{{#true?}}test{{#false?}}bar{{/true?}}{{/false?}}")
      end.to raise_exception(Curly::IncorrectEndingError)
    end

    it "does not execute arbitrary Ruby code" do
      evaluate('#{foo}').should == '#{foo}'
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
      presenter_class.stub(:available_components) { [:foo] }
      validate("Hello, {{inspect}}").should == false
    end

    it "returns true with a block" do
      validate("Hello {{#true?}}world{{/true?}}").should == true
    end

    it "returns false with an incomplete block" do
      validate("Hello {{#true?}}world").should == false
    end

    def validate(template)
      Curly.valid?(template, presenter_class)
    end
  end
end
