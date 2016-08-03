describe Curly::ComponentScanner do
  it "scans the component name, identifier, and attributes" do
    expect(scan('hello.world weather="sunny"')).to eq [
      "hello",
      "world",
      { "weather" => "sunny" },
      []
    ]
  end

  it "allows context namespaces" do
    expect(scan('island:beach:hello.world')).to eq [
      "hello",
      "world",
      {},
      ["island", "beach"]
    ]
  end

  it "allows a question mark after the identifier" do
    expect(scan('hello.world?')).to eq ["hello?", "world", {}, []]
  end

  it 'allows spaces before and after component' do
    expect(scan('  hello.world weather="sunny"   ')).to eq [
      "hello",
      "world",
      { "weather" => "sunny" },
      []
    ]
  end

  def scan(component)
    described_class.scan(component)
  end
end
