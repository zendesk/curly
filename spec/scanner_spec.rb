require 'spec_helper'

describe Curly::Scanner, ".scan" do
  it "returns the tokens in the source" do
    scan("foo {{bar}} baz {{qux}}").should == [
      [:text, "foo "],
      [:reference, "bar"],
      [:text, " baz "],
      [:reference, "qux"]
    ]
  end

  it "scans parameterized references" do
    scan("{{foo.bar}}").should == [
      [:reference, "foo.bar"]
    ]
  end

  it "allows references with whitespace" do
    scan("{{ foo bar}}").should == [
      [:reference, " foo bar"]
    ]
  end

  it "allows references with newline" do
    scan("foo {{bar\nbar}} baz").should == [
      [:text, "foo "],
      [:reference, "bar\nbar"],
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

  it "allows newlines in comments" do
    scan("{{!\nfoo\n}}").should == [
      [:comment, "\nfoo\n"]
    ]
  end

  it "scans comments with leading and trailing spaces" do
    scan("foo\n  {{!bar}}  \nbaz").should == [
      [:text, "foo\n  "],
      [:comment, "bar"],
      [:text, "  \nbaz"]
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

  it "raises Curly::SyntaxError on unclosed references" do
    ["{{", "{{yolo"].each do |template|
      expect { scan(template) }.to raise_error(Curly::SyntaxError)
    end
  end

  it "raises Curly::SyntaxError on unclosed comments" do
    ["{{!", "{{! foo bar"].each do |template|
      expect { scan(template) }.to raise_error(Curly::SyntaxError)
    end
  end

  def scan(source)
    Curly::Scanner.scan(source)
  end
end
