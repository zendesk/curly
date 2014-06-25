require 'spec_helper'

describe Curly::ReferenceCompiler do
  describe ".compile_conditional" do
    let(:presenter_class) do
      Class.new do
        def monday?
          true
        end

        def tuesday?
          false
        end

        def day?(name)
          name == "monday"
        end

        def season?(name:)
          name == "summer"
        end

        def hello
          "hello"
        end

        def self.method_available?(name)
          true
        end
      end
    end

    it "compiles simple references" do
      evaluate("monday?").should == true
      evaluate("tuesday?").should == false
    end

    it "compiles references with a parameter" do
      evaluate("day.monday?").should == true
      evaluate("day.tuesday?").should == false
    end

    it "compiles references with attributes" do
      evaluate("season? name=summer").should == true
      evaluate("season? name=winter").should == false
    end

    it "fails if the reference is missing a question mark" do
      expect { evaluate("hello") }.to raise_exception(Curly::Error)
    end

    def evaluate(reference, &block)
      method, argument, attributes = Curly::ReferenceParser.parse(reference)
      code = Curly::ReferenceCompiler.compile_conditional(presenter_class, method, argument, attributes)
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

  describe ".compile_reference" do
    let(:presenter_class) do
      Class.new do
        def title
          "Welcome!"
        end

        def i18n(key, fallback: nil)
          case key
          when "home.welcome" then "Welcome to our lovely place!"
          else fallback
          end
        end

        def summary(length = "long")
          case length
          when "long" then "This is a long summary"
          when "short" then "This is a short summary"
          end
        end

        def invalid(x, y)
        end

        def widget(size:, color: nil)
          s = "Widget (#{size})"
          s << " - #{color}" if color
          s
        end

        def self.method_available?(name)
          true
        end
      end
    end

    it "compiles parameterized references" do
      evaluate("i18n.home.welcome").should == "Welcome to our lovely place!"
    end

    it "compiles optionally parameterized references" do
      evaluate("summary").should == "This is a long summary"
      evaluate("summary.short").should == "This is a short summary"
    end

    it "compiles references with attributes" do
      evaluate("widget size=100px").should == "Widget (100px)"
    end

    it "compiles references with optional attributes" do
      evaluate("widget color=blue size=50px").should == "Widget (50px) - blue"
    end

    it "allows both parameter and attributes" do
      evaluate("i18n.hello fallback=yolo").should == "yolo"
    end

    it "fails when an invalid attribute is used" do
      expect { evaluate("i18n.foo extreme=true") }.to raise_exception(Curly::Error)
    end

    it "fails when a parameterized reference is missing a parameter" do
      expect { evaluate("i18n") }.to raise_exception(Curly::Error)
    end

    it "fails when a reference is missing a required attribute" do
      expect { evaluate("widget") }.to raise_exception(Curly::Error)
    end

    it "fails when a non-parameterized reference is passed a parameter" do
      expect { evaluate("title.rugby") }.to raise_exception(Curly::Error)
    end

    it "fails when the method takes more than one argument" do
      expect { evaluate("invalid") }.to raise_exception(Curly::Error)
    end

    def evaluate(reference, &block)
      method, argument, attributes = Curly::ReferenceParser.parse(reference)
      code = Curly::ReferenceCompiler.compile_reference(presenter_class, method, argument, attributes)
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
end
