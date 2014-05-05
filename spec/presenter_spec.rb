require 'spec_helper'

describe Curly::Presenter do
  class CircusPresenter < Curly::Presenter
    module MonkeyComponents
      def monkey
      end
    end

    include MonkeyComponents

    presents :midget, :clown, default: nil
    presents :elephant, default: "Dumbo"

    attr_reader :midget, :clown, :elephant, :horse

    deprecate_methods :horse
  end

  class FrenchCircusPresenter < CircusPresenter
    presents :elephant, default: "Babar"
  end

  class FancyCircusPresenter < CircusPresenter
    presents :champagne
  end

  describe "#initialize" do
    let(:context) { double("context") }

    it "sets the presented parameters as instance variables" do
      presenter = CircusPresenter.new(context,
        midget: "Meek Harolson",
        clown: "Bubbles"
      )

      presenter.midget.should == "Meek Harolson"
      presenter.clown.should == "Bubbles"
    end

    it "raises an exception if a required parameter is not specified" do
      expect {
        FancyCircusPresenter.new(context, {})
      }.to raise_exception(ArgumentError, "required parameter `champagne` missing")
    end

    it "allows specifying default values for parameters" do
      # Make sure subclasses can change default values.
      french_presenter = FrenchCircusPresenter.new(context)
      french_presenter.elephant.should == "Babar"

      # The subclass shouldn't change the superclass' defaults, though.
      presenter = CircusPresenter.new(context)
      presenter.elephant.should == "Dumbo"
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

  describe ".available_methods" do
    it "includes the methods on the presenter" do
      CircusPresenter.available_methods.should include(:midget)
    end

    it "does not include methods on the Curly::Presenter base class" do
      CircusPresenter.available_methods.should_not include(:cache_key)
    end

    it "does not include deprecated methods" do
      CircusPresenter.available_methods.should_not include(:horse)
    end
  end

  describe ".method_available?" do
    it "returns true if the method is available" do
      CircusPresenter.method_available?(:midget).should be_true
    end

    it "returns false if the method is not available" do
      CircusPresenter.method_available?(:bear).should be_false
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
