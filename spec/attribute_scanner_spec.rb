describe Curly::AttributeScanner do
  it "scans attributes" do
    scan("width=10px height=20px").should == {
      "width" => "10px",
      "height" => "20px"
    }
  end

  it "scans single quoted values" do
    scan("title='hello world'").should == { "title" => "hello world" }
  end

  it "scans double quoted values" do
    scan('title="hello world"').should == { "title" => "hello world" }
  end

  it "scans mixed quotes" do
    scan(%[x=y q="foo's bar" v='bim " bum' t="foo ' bar"]).should == {
      "x" => "y",
      "q" => "foo's bar",
      "t" => "foo ' bar",
      "v" => 'bim " bum'
    }
  end

  it "deals with weird whitespace" do
    scan(" size=big  ").should == { "size" => "big" }
  end

  it "scans empty attribute lists" do
    scan(nil).should == {}
    scan("").should == {}
    scan(" ").should == {}
  end

  it "fails when an invalid attribute list is passed" do
    expect { scan("foo") }.to raise_exception(Curly::AttributeError)
    expect { scan("foo=") }.to raise_exception(Curly::AttributeError)
  end

  def scan(str)
    described_class.scan(str)
  end
end
