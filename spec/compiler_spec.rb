describe Curly::Compiler do
  include CompilationSupport

  describe ".compile" do
    it "raises ArgumentError if the presenter class is nil" do
      expect do
        Curly::Compiler.compile("foo", nil)
      end.to raise_exception(ArgumentError)
    end

    it "makes sure only public methods are called on the presenter object" do
      expect { render("{{bar}}") }.to raise_exception(Curly::InvalidComponent)
    end

    it "includes the invalid component when failing to compile" do
      begin
        render("{{bar}}")
        fail
      rescue Curly::InvalidComponent => e
        expect(e.component).to eq "bar"
      end
    end

    it "propagates yields to the caller" do
      define_presenter do
        def i_want
          "I want #{yield}!"
        end
      end

      expect(render("{{i_want}}") { "$$$" }).to eq "I want $$$!"
    end

    it "sends along arguments passed to yield" do
      define_presenter do
        def hello(&block)
          "Hello, #{block.call('world')}!"
        end
      end

      expect(render("{{hello}}") {|v| v.upcase }).to eq "Hello, WORLD!"
    end

    it "escapes non HTML safe strings returned from the presenter" do
      define_presenter do
        def dirty
          "<p>dirty</p>"
        end
      end

      expect(render("{{dirty}}")).to eq "&lt;p&gt;dirty&lt;/p&gt;"
    end

    it "does not escape HTML safe strings returned from the presenter" do
      define_presenter do
        def dirty
          "<p>dirty</p>".html_safe
        end
      end

      expect(render("{{dirty}}")).to eq "<p>dirty</p>"
    end

    it "does not escape HTML in the template itself" do
      expect(render("<div>")).to eq "<div>"
    end

    it "treats all values returned from the presenter as strings" do
      define_presenter do
        def foo; 42; end
      end

      expect(render("{{foo}}")).to eq "42"
    end

    it "removes comments from the output" do
      expect(render("hello{{! I'm a comment, yo }}world")).to eq "helloworld"
    end

    it "removes text in false blocks" do
      define_presenter do
        def false?
          false
        end
      end

      expect(render("{{#false?}}wut{{/false?}}")).to eq ""
    end

    it "keeps text in true blocks" do
      define_presenter do
        def true?
          true
        end
      end

      expect(render("{{#true?}}yello{{/true?}}")).to eq "yello"
    end

    it "removes text in inverse true blocks" do
      define_presenter do
        def true?
          true
        end
      end

      expect(render("{{^true?}}bar{{/true?}}")).to eq ""
    end

    it "keeps text in inverse false blocks" do
      define_presenter do
        def false?
          false
        end
      end

      expect(render("{{^false?}}yeah!{{/false?}}")).to eq "yeah!"
    end

    it "passes an argument to blocks" do
      define_presenter do
        def hello?(value)
          value == "world"
        end
      end

      expect(render("{{#hello.world?}}foo{{/hello.world?}}")).to eq "foo"
      expect(render("{{#hello.mars?}}bar{{/hello.mars?}}")).to eq ""
    end

    it "passes attributes to blocks" do
      define_presenter do
        def square?(width:, height:)
          width.to_i == height.to_i
        end
      end

      expect(render("{{#square? width=2 height=2}}yeah!{{/square?}}")).to eq "yeah!"
    end

    it "gives an error on incomplete blocks" do
      expect do
        render("{{#hello?}}")
      end.to raise_exception(Curly::IncompleteBlockError)
    end

    it "gives an error when closing unopened blocks" do
      expect do
        render("{{/goodbye?}}")
      end.to raise_exception(Curly::IncorrectEndingError)
    end

    it "gives an error on mismatching block ends" do
      expect do
        render("{{#x?}}{{#y?}}{{/x?}}{{/y?}}")
      end.to raise_exception(Curly::IncorrectEndingError)
    end

    it "does not execute arbitrary Ruby code" do
      expect(render('#{foo}')).to eq '#{foo}'
    end
  end

  describe ".valid?" do
    it "returns true if only available methods are referenced" do
      define_presenter do
        def foo; end
      end

      expect(validate("Hello, {{foo}}!")).to eq true
    end

    it "returns false if a missing method is referenced" do
      define_presenter
      expect(validate("Hello, {{i_am_missing}}")).to eq false
    end

    it "returns false if an unavailable method is referenced" do
      define_presenter do
        def self.available_components
          []
        end
      end

      expect(validate("Hello, {{inspect}}")).to eq false
    end

    def validate(template)
      Curly.valid?(template, ShowPresenter)
    end
  end
end
