require 'spec_helper'

describe Curly::ComponentScanner do
  it "scans the component name, identifier, and attributes" do
    scan('hello.world weather="sunny"').should == [
      "hello",
      "world",
      { "weather" => "sunny" }
    ]
  end

  it "allows a question mark after the identifier" do
    scan('hello.world?').should == ["hello?", "world", {}]
  end

  def scan(component)
    described_class.scan(component)
  end
end
