require 'spec_helper'

describe Curly::Presenter do
  class CircusPresenter < Curly::Presenter
    module MonkeyComponents
      def monkey
      end
    end

    include MonkeyComponents

    presents :midget, :clown
    attr_reader :midget, :clown
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

  describe ".presenter_for_path" do
    it "returns the presenter class for the given path" do
      presenter = double("presenter")
      stub_const("Foo::BarPresenter", presenter)

      Curly::Presenter.presenter_for_path("foo/bar").should == presenter
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
  end
end
