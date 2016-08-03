describe Curly::AttributeScanner do
  it "scans attributes" do
    expect(scan("width=10px height=20px")).to eq({
      "width" => "10px",
      "height" => "20px"
    })
  end

  it "scans single quoted values" do
    expect(scan("title='hello world'")).to eq({ "title" => "hello world" })
  end

  it "scans double quoted values" do
    expect(scan('title="hello world"')).to eq({ "title" => "hello world" })
  end

  it "scans mixed quotes" do
    expect(scan(%[x=y q="foo's bar" v='bim " bum' t="foo ' bar"])).to eq({
      "x" => "y",
      "q" => "foo's bar",
      "t" => "foo ' bar",
      "v" => 'bim " bum'
    })
  end

  it "deals with weird whitespace" do
    expect(scan(" size=big  ")).to eq({ "size" => "big" })
  end

  it "scans empty attribute lists" do
    expect(scan(nil)).to eq({})
    expect(scan("")).to eq({})
    expect(scan(" ")).to eq({})
  end

  it "fails when an invalid attribute list is passed" do
    expect { scan("foo") }.to raise_exception(Curly::AttributeError)
    expect { scan("foo=") }.to raise_exception(Curly::AttributeError)
  end

  def scan(str)
    described_class.scan(str)
  end
end
