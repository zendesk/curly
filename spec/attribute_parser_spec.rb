require 'spec_helper'

describe Curly::AttributeParser do
  it "parses attributes" do
    parse("width=10px height=20px").should == {
      "width" => "10px",
      "height" => "20px"
    }
  end

  it "parses single quoted values" do
    parse("title='hello world'").should == { "title" => "hello world" }
  end

  it "parses double quoted values" do
    parse('title="hello world"').should == { "title" => "hello world" }
  end

  it "parses mixed quotes" do
    parse(%[x=y q="foo's bar" v='bim " bum' t="foo ' bar"]).should == {
      "x" => "y",
      "q" => "foo's bar",
      "t" => "foo ' bar",
      "v" => 'bim " bum'
    }
  end

  it "deals with weird whitespace" do
    parse(" size=big  ").should == { "size" => "big" }
  end

  it "parses empty attribute lists" do
    parse(nil).should == {}
    parse("").should == {}
    parse(" ").should == {}
  end

  it "fails when an invalid attribute list is passed" do
    expect { parse("foo") }.to raise_exception(Curly::AttributeError)
    expect { parse("foo=") }.to raise_exception(Curly::AttributeError)
  end

  def parse(str)
    described_class.parse(str)
  end
end
