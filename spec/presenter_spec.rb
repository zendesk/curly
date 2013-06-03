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

    attr_reader :midget, :clown, :elephant

    def content_for_circus_name!
      "Circus Arli"
    end
  end

  class FrenchCircusPresenter < CircusPresenter
    presents :elephant, default: "Babar"
  end

  it "sets the presented parameters as instance variables" do
    context = double("context")

    presenter = CircusPresenter.new(context,
      midget: "Meek Harolson",
      clown: "Bubbles"
    )

    presenter.midget.should == "Meek Harolson"
    presenter.clown.should == "Bubbles"
  end

  it "allows specifying default values for parameters" do
    context = double("context")

    # Make sure subclasses can change default values.
    french_presenter = FrenchCircusPresenter.new(context)
    french_presenter.elephant.should == "Babar"

    # The subclass shouldn't change the superclass' defaults, though.
    presenter = CircusPresenter.new(context)
    presenter.elephant.should == "Dumbo"
  end

  describe "#content_for_values" do
    it "returns a hash of the content_for key-value pairs" do
      context = double("context")
      presenter = CircusPresenter.new(context)

      presenter.content_for_values.should == { circus_name: "Circus Arli" }
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
end
