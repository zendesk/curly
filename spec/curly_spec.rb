require 'spec_helper'
require 'curly'

describe Curly do
  let(:presenter_class) { Class.new }

  describe ".valid?" do
    before do
      presenter_class.stub(:available_methods) { [:foo] }
    end

    it "returns true if only available methods are referenced" do
      validate("Hello, {{foo}}!").should == true
    end

    it "returns false if a missing method is referenced" do
      validate("Hello, {{i_am_missing}}").should == false
    end

    it "returns false if an unavailable method is referenced" do
      validate("Hello, {{inspect}}").should == false
    end

    def validate(template)
      Curly.valid?(template, presenter_class)
    end
  end
end
