describe Curly::Scanner, ".scan" do
  it "returns the tokens in the source" do
    expect(scan("foo {{bar}} baz")).to eq [
      [:text, "foo "],
      [:component, "bar", nil, {}, []],
      [:text, " baz"]
    ]
  end

  it "scans components with identifiers" do
    expect(scan("{{foo.bar}}")).to eq [
      [:component, "foo", "bar", {}, []]
    ]
  end

  it "scans comments in the source" do
    expect(scan("foo {{!bar}} baz")).to eq [
      [:text, "foo "],
      [:comment, "bar"],
      [:text, " baz"]
    ]
  end

  it "allows newlines in comments" do
    expect(scan("{{!\nfoo\n}}")).to eq [
      [:comment, "\nfoo\n"]
    ]
  end

  it "scans to the end of the source" do
    expect(scan("foo\n")).to eq [
      [:text, "foo\n"]
    ]
  end

  it "allows escaping Curly quotes" do
    expect(scan('foo {{{ bar')).to eq [
      [:text, "foo "],
      [:text, "{{"],
      [:text, " bar"]
    ]

    expect(scan('foo }} bar')).to eq [
      [:text, "foo }} bar"]
    ]

    expect(scan('foo {{{ lala! }} bar')).to eq [
      [:text, "foo "],
      [:text, "{{"],
      [:text, " lala! }} bar"]
    ]
  end

  it "scans context block tags" do
    expect(scan('{{@search_form}}{{query_field}}{{/search_form}}')).to eq [
      [:context_block_start, "search_form", nil, {}, []],
      [:component, "query_field", nil, {}, []],
      [:block_end, "search_form", nil, {}, []]
    ]
  end

  it "scans conditional block tags" do
    expect(scan('foo {{#bar?}} hello {{/bar?}}')).to eq [
      [:text, "foo "],
      [:conditional_block_start, "bar?", nil, {}, []],
      [:text, " hello "],
      [:block_end, "bar?", nil, {}, []]
    ]
  end

  it "scans conditional block tags with the if syntax" do
    scan('foo {{#if bar?}} hello {{/if}}').should == [
      [:text, "foo "],
      [:conditional_block_start, "bar?", nil, {}],
      [:text, " hello "],
      [:conditional_block_end, nil, nil]
    ]
  end

  it "scans conditional block tags with the else token" do
    scan('foo {{#if bar?}} hello {{else}} bye {{/if}}').should == [
      [:text, "foo "],
      [:conditional_block_start, "bar?", nil, {}],
      [:text, " hello "],
      [:else_block_start, nil, nil],
      [:text, " bye "],
      [:conditional_block_end, nil, nil]
    ]
  end

  it "scans conditional block tags with parameters and attributes" do
    expect(scan('{{#active.test? name="test"}}yo{{/active.test?}}')).to eq [
      [:conditional_block_start, "active?", "test", { "name" => "test" }, []],
      [:text, "yo"],
      [:block_end, "active?", "test", {}, []]
    ]
  end

  it "scans inverse block tags" do
    expect(scan('foo {{^bar?}} hello {{/bar?}}')).to eq [
      [:text, "foo "],
      [:inverse_conditional_block_start, "bar?", nil, {}, []],
      [:text, " hello "],
      [:block_end, "bar?", nil, {}, []]
    ]
  end

  it "scans collection block tags" do
    expect(scan('foo {{*bar}} hello {{/bar}}')).to eq [
      [:text, "foo "],
      [:collection_block_start, "bar", nil, {}, []],
      [:text, " hello "],
      [:block_end, "bar", nil, {}, []]
    ]
  end

  it "treats quotes as text" do
    expect(scan('"')).to eq [
      [:text, '"']
    ]
  end

  it "treats Ruby interpolation as text" do
    expect(scan('#{foo}')).to eq [
      [:text, '#{foo}']
    ]
  end

  it "raises Curly::SyntaxError on unclosed components" do
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
