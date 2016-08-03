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
    presents :puma, default: -> { 'block' }
    presents(:lion) { @elephant.upcase }
    presents(:something) { self }

    attr_reader :midget, :clown, :elephant, :puma, :lion, :something
  end

  class FrenchCircusPresenter < CircusPresenter
    presents :elephant, default: "Babar"
  end

  class FancyCircusPresenter < CircusPresenter
    presents :champagne
  end

  class CircusPresenter::MonkeyPresenter < Curly::Presenter
  end

  module PresenterContainer
    class NestedPresenter < Curly::Presenter
    end
    module PresenterSubcontainer
      class SubNestedPresenter < Curly::Presenter
      end
    end
  end

  describe "#initialize" do
    let(:context) { double("context") }

    it "sets the presented identifiers as instance variables" do
      presenter = CircusPresenter.new(context,
        midget: "Meek Harolson",
        clown: "Bubbles"
      )

      expect(presenter.midget).to eq "Meek Harolson"
      expect(presenter.clown).to eq "Bubbles"
    end

    it "raises an exception if a required identifier is not specified" do
      expect {
        FancyCircusPresenter.new(context, {})
      }.to raise_exception(ArgumentError, "required identifier `champagne` missing")
    end

    it "allows specifying default values for identifiers" do
      # Make sure subclasses can change default values.
      french_presenter = FrenchCircusPresenter.new(context)
      expect(french_presenter.elephant).to eq "Babar"
      expect(french_presenter.lion).to eq 'BABAR'
      expect(french_presenter.puma).to be_a Proc

      # The subclass shouldn't change the superclass' defaults, though.
      presenter = CircusPresenter.new(context)
      expect(presenter.elephant).to eq "Dumbo"
      expect(presenter.lion).to eq 'DUMBO'
      expect(presenter.puma).to be_a Proc
    end

    it "doesn't call a block if given as a value for identifiers" do
      lion = proc { 'Simba' }
      presenter = CircusPresenter.new(context, lion: lion)
      expect(presenter.lion).to be lion
    end

    it "calls default blocks in the instance of the presenter" do
      presenter = CircusPresenter.new(context)
      expect(presenter.something).to be presenter
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
      expect(context).to receive(:undefined).once
      subject.undefined
    end

    it "allows method calls on context-defined methods" do
      expect(context).to receive(:respond_to?).
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
      expect(context).to receive(:foo).once
      expect(subject).not_to receive(:method_missing)
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

      expect(Curly::Presenter.presenter_for_path("foo/bar")).to eq presenter
    end

    it "returns nil if there is no presenter for the given path" do
      expect(Curly::Presenter.presenter_for_path("foo/bar")).to be_nil
    end
  end

  describe ".presenter_for_name" do
    it 'looks through the container namespaces' do
      expect(PresenterContainer::PresenterSubcontainer::SubNestedPresenter.presenter_for_name('nested')).to eq PresenterContainer::NestedPresenter
    end

    it 'looks through the container namespaces' do
      expect(Curly::Presenter.presenter_for_name('presenter_container/presenter_subcontainer/nested', [])).to eq(PresenterContainer::NestedPresenter)
    end

    it "returns the presenter class for the given name" do
      expect(CircusPresenter.presenter_for_name("monkey")).to eq CircusPresenter::MonkeyPresenter
    end

    it "looks in the namespace" do
      expect(CircusPresenter.presenter_for_name("french_circus")).to eq FrenchCircusPresenter
    end

    it "returns Curly::PresenterNameError if the presenter class doesn't exist" do
      expect { CircusPresenter.presenter_for_name("clown") }.to raise_exception(Curly::PresenterNameError)
    end
  end

  describe ".available_components" do
    it "includes the methods on the presenter" do
      expect(CircusPresenter.available_components).to include("midget")
    end

    it "does not include methods on the Curly::Presenter base class" do
      expect(CircusPresenter.available_components).not_to include("cache_key")
    end
  end

  describe ".component_available?" do
    it "returns true if the method is available" do
      expect(CircusPresenter.component_available?("midget")).to eq true
    end

    it "returns false if the method is not available" do
      expect(CircusPresenter.component_available?("bear")).to eq false
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

      expect(presenter1.version).to eq 42
      expect(presenter2.version).to eq 1337
    end

    it "returns 0 if no version has been set" do
      presenter = Class.new(Curly::Presenter)
      expect(presenter.version).to eq 0
    end
  end

  describe ".cache_key" do
    it "includes the presenter's class name and version" do
      presenter = Class.new(Curly::Presenter) { version 42 }
      stub_const("Foo::BarPresenter", presenter)

      expect(Foo::BarPresenter.cache_key).to eq "Foo::BarPresenter/42"
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
      expect(cache_key).to eq "Foo::BarPresenter/42/Foo::BumPresenter/1337"
    end

    it "uses the view path of a dependency if there is no presenter for it" do
      presenter = Class.new(Curly::Presenter) do
        version 42
        depends_on 'foo/bum'
      end

      stub_const("Foo::BarPresenter", presenter)

      cache_key = Foo::BarPresenter.cache_key
      expect(cache_key).to eq "Foo::BarPresenter/42/foo/bum"
    end
  end

  describe ".dependencies" do
    it "returns the dependencies defined for the presenter" do
      presenter = Class.new(Curly::Presenter) { depends_on 'foo' }
      expect(presenter.dependencies.to_a).to eq ['foo']
    end

    it "includes the dependencies defined for parent classes" do
      Curly::Presenter.dependencies
      parent = Class.new(Curly::Presenter) { depends_on 'foo' }
      presenter = Class.new(parent) { depends_on 'bar' }
      expect(presenter.dependencies.to_a).to match_array ['foo', 'bar']
    end
  end
end
