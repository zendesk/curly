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
        e.component.should == "bar"
      end
    end

    it "propagates yields to the caller" do
      define_presenter do
        def i_want
          "I want #{yield}!"
        end
      end

      render("{{i_want}}") { "$$$" }.should == "I want $$$!"
    end

    it "sends along arguments passed to yield" do
      define_presenter do
        def hello(&block)
          "Hello, #{block.call('world')}!"
        end
      end

      render("{{hello}}") {|v| v.upcase }.should == "Hello, WORLD!"
    end

    it "escapes non HTML safe strings returned from the presenter" do
      define_presenter do
        def dirty
          "<p>dirty</p>"
        end
      end

      render("{{dirty}}").should == "&lt;p&gt;dirty&lt;/p&gt;"
    end

    it "does not escape HTML safe strings returned from the presenter" do
      define_presenter do
        def dirty
          "<p>dirty</p>".html_safe
        end
      end

      render("{{dirty}}").should == "<p>dirty</p>"
    end

    it "does not escape HTML in the template itself" do
      render("<div>").should == "<div>"
    end

    it "treats all values returned from the presenter as strings" do
      define_presenter do
        def foo; 42; end
      end

      render("{{foo}}").should == "42"
    end

    it "removes comments from the output" do
      render("hello{{! I'm a comment, yo }}world").should == "helloworld"
    end

    it "removes text in false blocks" do
      define_presenter do
        def false?
          false
        end
      end

      render("{{#false?}}wut{{/false?}}").should == ""
    end

    it "keeps text in true blocks" do
      define_presenter do
        def true?
          true
        end
      end

      render("{{#true?}}yello{{/true?}}").should == "yello"
    end

    it "removes text in inverse true blocks" do
      define_presenter do
        def true?
          true
        end
      end

      render("{{^true?}}bar{{/true?}}").should == ""
    end

    it "keeps text in inverse false blocks" do
      define_presenter do
        def false?
          false
        end
      end

      render("{{^false?}}yeah!{{/false?}}").should == "yeah!"
    end

    it "passes an argument to blocks" do
      define_presenter do
        def hello?(value)
          value == "world"
        end
      end

      render("{{#hello.world?}}foo{{/hello.world?}}").should == "foo"
      render("{{#hello.mars?}}bar{{/hello.mars?}}").should == ""
    end

    it "passes attributes to blocks" do
      define_presenter do
        def square?(width:, height:)
          width.to_i == height.to_i
        end
      end

      render("{{#square? width=2 height=2}}yeah!{{/square?}}").should == "yeah!"
    end

    it "caches context blocks" do
      define_presenter do
        presents :author

        def author(&block)
          block.call(@author)
        end
      end

      define_presenter "AuthorPresenter" do
        presents :author

        def name
          @author.name
        end

        def cache_key
          "static"
        end
      end

      author = double("author", name: "john")
      template = "{{@author}}{{name}}{{/author}}"

      expect(render(template, locals: { author: author })).to eq "john"

      author.stub(:name) { "jane" }

      expect(render(template, locals: { author: author })).to eq "john"
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
      render('#{foo}').should == '#{foo}'
    end
  end

  describe ".valid?" do
    it "returns true if only available methods are referenced" do
      define_presenter do
        def foo; end
      end

      validate("Hello, {{foo}}!").should == true
    end

    it "returns false if a missing method is referenced" do
      define_presenter
      validate("Hello, {{i_am_missing}}").should == false
    end

    it "returns false if an unavailable method is referenced" do
      define_presenter do
        def self.available_components
          []
        end
      end

      validate("Hello, {{inspect}}").should == false
    end

    def validate(template)
      Curly.valid?(template, ShowPresenter)
    end
  end
end
