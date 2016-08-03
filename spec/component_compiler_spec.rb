describe Curly::ComponentCompiler do
  describe ".compile" do
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

        def collected(**options)
          options.to_a.map { |(k, v)| "#{k}: #{v}" }.join("\n")
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

        def form(&block)
          "some form"
        end

        def self.component_available?(name)
          true
        end
      end
    end

    it "compiles components with identifiers" do
      expect(evaluate("i18n.home.welcome")).to eq "Welcome to our lovely place!"
    end

    it "compiles components with optional identifiers" do
      expect(evaluate("summary")).to eq "This is a long summary"
      expect(evaluate("summary.short")).to eq "This is a short summary"
    end

    it "compiles components with attributes" do
      expect(evaluate("widget size=100px")).to eq "Widget (100px)"
    end

    it "compiles components with collected attributes" do
      expect(evaluate("collected class=test for=you")).to eq "class: test\nfor: you"
    end

    it "compiles components with optional attributes" do
      expect(evaluate("widget color=blue size=50px")).to eq "Widget (50px) - blue"
    end

    it "compiles context block components" do
      expect(evaluate("form", type: :context)).to eq "some form"
    end

    it "allows both identifier and attributes" do
      expect(evaluate("i18n.hello fallback=yolo")).to eq "yolo"
    end

    it "fails when an invalid attribute is used" do
      expect { evaluate("i18n.foo extreme=true") }.to raise_exception(Curly::Error)
    end

    it "fails when a component is missing a required identifier" do
      expect { evaluate("i18n") }.to raise_exception(Curly::Error)
    end

    it "fails when a component is missing a required attribute" do
      expect { evaluate("widget") }.to raise_exception(Curly::Error)
    end

    it "fails when an identifier is specified for a component that doesn't support one" do
      expect { evaluate("title.rugby") }.to raise_exception(Curly::Error)
    end

    it "fails when the method takes more than one argument" do
      expect { evaluate("invalid") }.to raise_exception(Curly::Error)
    end

    it "fails when a context block component is used with a method that doesn't take a block" do
      expect { evaluate("title", type: :context) }.to raise_exception(Curly::Error)
    end
  end

  def evaluate(text, type: nil, &block)
    name, identifier, attributes = Curly::ComponentScanner.scan(text)
    component = Curly::Parser::Component.new(name, identifier, attributes)
    code = Curly::ComponentCompiler.compile(presenter_class, component, type: type)
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
