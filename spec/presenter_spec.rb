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
end
