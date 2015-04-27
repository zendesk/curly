describe Curly::Presenter do
  class CircusPresenter < Curly::Presenter
    module MonkeyComponents
      def monkey
      end
    end

    exposes_helper :foo

    include MonkeyComponents

    presents :midget, :clown, default: nil
    presents :elephant, default: "Dumbo"

    attr_reader :midget, :clown, :elephant

    def alpha(name, age: 12)
      name
    end

    def beta(test:, this: "thing")
      test + this
    end

    def charlie(&test)
    end

    def delta?
      false
    end

    def cats
    end

    class CatPresenter < Curly::Presenter; end
  end

  class FrenchCircusPresenter < CircusPresenter
    presents :elephant, default: "Babar"
  end

  class FancyCircusPresenter < CircusPresenter
    presents :champagne
  end

  class CircusPresenter::MonkeyPresenter < Curly::Presenter
  end

  describe "#initialize" do
    let(:context) { double("context") }

    it "sets the presented identifiers as instance variables" do
      presenter = CircusPresenter.new(context,
        midget: "Meek Harolson",
        clown: "Bubbles"
      )

      presenter.midget.should == "Meek Harolson"
      presenter.clown.should == "Bubbles"
    end

    it "raises an exception if a required identifier is not specified" do
      expect {
        FancyCircusPresenter.new(context, {})
      }.to raise_exception(ArgumentError, "required identifier `champagne` missing")
    end

    it "allows specifying default values for identifiers" do
      # Make sure subclasses can change default values.
      french_presenter = FrenchCircusPresenter.new(context)
      french_presenter.elephant.should == "Babar"

      # The subclass shouldn't change the superclass' defaults, though.
      presenter = CircusPresenter.new(context)
      presenter.elephant.should == "Dumbo"
    end
  end

  describe "#method_missing" do
    let(:context) { double("context") }
    subject {
      CircusPresenter.new(context,
        midget: "Meek Harolson",
        clown: "Bubbles")
    }

    it "delegates calls to the context" do
      context.should receive(:undefined).once
      subject.undefined
    end

    it "allows method calls on context-defined methods" do
      context.should receive(:respond_to?).
        with(:undefined, false).once.and_return(true)
      subject.method(:undefined)
    end
  end

  describe ".exposes_helper" do
    let(:context) { double("context") }
    subject {
      CircusPresenter.new(context,
        midget: "Meek Harolson",
        clown: "Bubbles")
    }

    it "allows a method as a component" do
      CircusPresenter.component_available?(:foo)
    end

    it "delegates the call to the context" do
      context.should receive(:foo).once
      subject.should_not receive(:method_missing)
      subject.foo
    end

    it "doesn't delegate other calls to the context" do
      expect { subject.bar }.to raise_error
    end
  end

  describe ".presenter_for_path" do
    it "returns the presenter class for the given path" do
      presenter = double("presenter")
      stub_const("Foo::BarPresenter", presenter)

      Curly::Presenter.presenter_for_path("foo/bar").should == presenter
    end

    it "returns nil if there is no presenter for the given path" do
      Curly::Presenter.presenter_for_path("foo/bar").should be_nil
    end

    it "does not swallow exceptions" do
      error = NameError.new("omg!", :baz)
      String.any_instance.stub(:constantize).and_raise(error)

      expect do
        Curly::Presenter.presenter_for_path("foo/bar")
      end.to raise_error(NameError)
    end
  end

  describe ".presenter_for_name" do
    it "returns the presenter class for the given name" do
      CircusPresenter.presenter_for_name("monkey").should == CircusPresenter::MonkeyPresenter
    end

    it "looks in the namespace" do
      CircusPresenter.presenter_for_name("french_circus").should == FrenchCircusPresenter
    end

    it "returns NameError if the presenter class doesn't exist" do
      expect { CircusPresenter.presenter_for_name("clown") }.to raise_exception(NameError)
    end
  end

  describe ".available_components" do
    it "includes the methods on the presenter" do
      CircusPresenter.available_components.should include("midget")
    end

    it "does not include methods on the Curly::Presenter base class" do
      CircusPresenter.available_components.should_not include("cache_key")
    end
  end

  describe ".component_available?" do
    it "returns true if the method is available" do
      CircusPresenter.component_available?("midget").should == true
    end

    it "returns false if the method is not available" do
      CircusPresenter.component_available?("bear").should == false
    end
  end

  describe ".description" do
    it "gives a hash" do
      CircusPresenter.description.should be_a Hash
    end

    it "describes the components" do
      description = CircusPresenter.description

      description[:components].should have(9).items
      description[:components].should == [
        { name: "midget",
          type: "value",
          attributes: [],
          identifier: nil,
          block: false },
        { name: "clown",
          type: "value",
          attributes: [],
          identifier: nil,
          block: false },
        { name: "elephant",
          type: "value",
          attributes: [],
          identifier: nil,
          block: false },

        { name: "alpha",
          type: "value",
          attributes: [
            { name: "age", required: false }],
          identifier: { name: "name", required: true },
          block: false },

        { name: "beta",
          type: "value",
          attributes: [
            { name: "test", required: true },
            { name: "this", required: false }],
          identifier: nil,
          block: false },

        { name: "charlie",
          type: "value",
          attributes: [],
          identifier: nil,
          block: "test" },

        { name: "delta?",
          type: "conditional",
          attributes: [],
          identifier: nil,
          block: false },
        { name: "cats",
          type: "collection",
          attributes: [],
          identifier: nil,
          block: false },
        { name: "monkey",
          type: "context",
          attributes: [],
          identifier: nil,
          block: false }
      ]
    end
  end

  describe ".version" do
    it "sets the version of the presenter" do
      presenter1 = Class.new(Curly::Presenter) do
        version 42
      end

      presenter2 = Class.new(Curly::Presenter) do
        version 1337
      end

      presenter1.version.should == 42
      presenter2.version.should == 1337
    end

    it "returns 0 if no version has been set" do
      presenter = Class.new(Curly::Presenter)
      presenter.version.should == 0
    end
  end

  describe ".cache_key" do
    it "includes the presenter's class name and version" do
      presenter = Class.new(Curly::Presenter) { version 42 }
      stub_const("Foo::BarPresenter", presenter)

      Foo::BarPresenter.cache_key.should == "Foo::BarPresenter/42"
    end

    it "includes the cache keys of presenters in the dependency list" do
      presenter = Class.new(Curly::Presenter) do
        version 42
        depends_on 'foo/bum'
      end

      dependency = Class.new(Curly::Presenter) do
        version 1337
      end

      stub_const("Foo::BarPresenter", presenter)
      stub_const("Foo::BumPresenter", dependency)

      cache_key = Foo::BarPresenter.cache_key
      cache_key.should == "Foo::BarPresenter/42/Foo::BumPresenter/1337"
    end

    it "uses the view path of a dependency if there is no presenter for it" do
      presenter = Class.new(Curly::Presenter) do
        version 42
        depends_on 'foo/bum'
      end

      stub_const("Foo::BarPresenter", presenter)

      cache_key = Foo::BarPresenter.cache_key
      cache_key.should == "Foo::BarPresenter/42/foo/bum"
    end
  end

  describe ".dependencies" do
    it "returns the dependencies defined for the presenter" do
      presenter = Class.new(Curly::Presenter) { depends_on 'foo' }
      presenter.dependencies.to_a.should == ['foo']
    end

    it "includes the dependencies defined for parent classes" do
      Curly::Presenter.dependencies
      parent = Class.new(Curly::Presenter) { depends_on 'foo' }
      presenter = Class.new(parent) { depends_on 'bar' }
      presenter.dependencies.to_a.should =~ ['foo', 'bar']
    end
  end
end
