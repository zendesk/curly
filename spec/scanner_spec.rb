require 'spec_helper'

describe Curly::Scanner, ".scan" do
  it "returns the tokens in the source" do
    scan("foo {{bar}} baz").should == [
      [:text, "foo "],
      [:reference, "bar"],
      [:text, " baz"]
    ]
  end

  it "scans parameterized references" do
    scan("{{foo.bar}}").should == [
      [:reference, "foo.bar"]
    ]
  end

  it "scans comments in the source" do
    scan("foo {{!bar}} baz").should == [
      [:text, "foo "],
      [:comment, "bar"],
      [:text, " baz"]
    ]
  end

  it "scans comment lines in the source" do
    scan("foo\n{{!bar}}\nbaz").should == [
      [:text, "foo\n"],
      [:comment_line, "bar"],
      [:text, "baz"]
    ]
  end

  it "scans to the end of the source" do
    scan("foo\n").should == [
      [:text, "foo\n"]
    ]
  end

  it "treats quotes as text" do
    scan('"').should == [
      [:text, '"']
    ]
  end

  it "treats Ruby interpolation as text" do
    scan('#{foo}').should == [
      [:text, '#{foo}']
    ]
  end

  def scan(source)
    Curly::Scanner.scan(source)
  end
end
