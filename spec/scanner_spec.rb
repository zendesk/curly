require 'spec_helper'

describe Curly::Scanner, ".scan" do
  it "returns the tokens in the source" do
    scan("foo {{bar}} baz").should == [
      [:text, "foo "],
      [:reference, "bar"],
      [:text, " baz"]
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

  def scan(source)
    Curly::Scanner.scan(source)
  end
end
