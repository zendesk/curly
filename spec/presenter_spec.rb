require 'spec_helper'
require 'active_support/all'
require 'curly/presenter'

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

  describe ".available_components" do
    it "includes all components that are available from the presenter" do
      components.should include(:midget)
      components.should include(:clown)
    end

    it "includes components that have been included from modules" do
      components.should include(:monkey)
    end

    it "excludes built-in protocol methods" do
      components.should_not include(:cache_key)
      components.should_not include(:cache_duration)
    end

    it "excludes non-presenter methods" do
      components.should_not include(:==)
    end

    def components
      CircusPresenter.available_components
    end
  end
end
