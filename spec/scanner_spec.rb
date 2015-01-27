describe Curly::Scanner, ".scan" do
  it "returns the tokens in the source" do
    scan("foo {{bar}} baz").should == [
      [:text, "foo "],
      [:component, "bar", nil, {}],
      [:text, " baz"]
    ]
  end

  it "scans components with identifiers" do
    scan("{{foo.bar}}").should == [
      [:component, "foo", "bar", {}]
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

  it "scans to the end of the source" do
    scan("foo\n").should == [
      [:text, "foo\n"]
    ]
  end

  it "allows escaping Curly quotes" do
    scan('foo {{{ bar').should == [
      [:text, "foo "],
      [:text, "{{"],
      [:text, " bar"]
    ]

    scan('foo }} bar').should == [
      [:text, "foo }} bar"]
    ]

    scan('foo {{{ lala! }} bar').should == [
      [:text, "foo "],
      [:text, "{{"],
      [:text, " lala! }} bar"]
    ]
  end

  it "scans context block tags" do
    scan('{{@search_form}}{{query_field}}{{/search_form}}').should == [
      [:context_block_start, "search_form", nil, {}],
      [:component, "query_field", nil, {}],
      [:block_end, "search_form", nil]
    ]
  end

  it "scans conditional block tags" do
    scan('foo {{#bar?}} hello {{/bar?}}').should == [
      [:text, "foo "],
      [:conditional_block_start, "bar?", nil, {}],
      [:text, " hello "],
      [:block_end, "bar?", nil]
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
    scan('{{#active.test? name="test"}}yo{{/active.test?}}').should == [
      [:conditional_block_start, "active?", "test", { "name" => "test" }],
      [:text, "yo"],
      [:block_end, "active?", "test"]
    ]
  end

  it "scans inverse block tags" do
    scan('foo {{^bar?}} hello {{/bar?}}').should == [
      [:text, "foo "],
      [:inverse_conditional_block_start, "bar?", nil, {}],
      [:text, " hello "],
      [:block_end, "bar?", nil]
    ]
  end

  it "scans inverse block tags using the unless syntax" do
    scan('foo {{#unless bar?}} hello {{/unless}}').should == [
      [:text, "foo "],
      [:inverse_conditional_block_start, "bar?", nil, {}],
      [:text, " hello "],
      [:inverse_conditional_block_end, nil, nil]
    ]
  end

  it "scans inverse conditional block tags with the else token" do
    scan('foo {{#unless bar?}} hello {{else}} bye {{/if}}').should == [
      [:text, "foo "],
      [:inverse_conditional_block_start, "bar?", nil, {}],
      [:text, " hello "],
      [:else_block_start, nil, nil],
      [:text, " bye "],
      [:conditional_block_end, nil, nil]
    ]
  end

  it "scans collection block tags" do
    scan('foo {{*bar}} hello {{/bar}}').should == [
      [:text, "foo "],
      [:collection_block_start, "bar", nil, {}],
      [:text, " hello "],
      [:block_end, "bar", nil]
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
