require 'spec_helper'

describe Curly::IncorrectEndingError do
  it "has a nice error message" do
    error = Curly::IncorrectEndingError.new(["bar", nil], ["foo", nil])
    error.message.should == "compilation error: expected `{{/foo}}`, got `{{/bar}}`"
  end

  it "handles components with an identifier" do
    error = Curly::IncorrectEndingError.new(["foo", "y"], ["foo", "x"])
    error.message.should == "compilation error: expected `{{/foo.x}}`, got `{{/foo.y}}`"
  end
end
