describe Curly::Parser do
  it "parses component tokens" do
    tokens = [
      [:component, "a", nil, {}],
    ]

    parse(tokens).should == [
      component("a")
    ]
  end

  it "parses conditional blocks" do
    tokens = [
      [:conditional_block_start, "a?", nil, {}],
      [:component, "hello", nil, {}],
      [:block_end, "a?", nil],
    ]

    parse(tokens).should == [
      conditional_block(component("a?"), [component("hello")])
    ]
  end

  it "parses conditional blocks with the if syntax" do
    tokens = [
      [:conditional_block_start, "a?", nil, {}],
      [:component, "hello", nil, {}],
      [:conditional_block_end, nil, nil],
    ]

    parse(tokens).should == [
      conditional_block(component("a?"), [component("hello")])
    ]
  end

  it "parses inverse conditional blocks" do
    tokens = [
      [:inverse_conditional_block_start, "a?", nil, {}],
      [:component, "hello", nil, {}],
      [:block_end, "a?", nil],
    ]

    parse(tokens).should == [
      inverse_conditional_block(component("a?"), [component("hello")])
    ]
  end

  it "parses elses in conditionals" do
    tokens = [
      [:conditional_block_start, "bar?", nil, {}],
      [:component, "hello", nil, {}],
      [:else_block_start, "bar?", nil, {}],
      [:component, "bye", nil, {}],
      [:block_end, "bar?", nil],
    ]

    parse(tokens).should == [
      conditional_block(component("bar?"), [component("hello")], [component("bye")])
    ]
  end

  it "parses elses in inverse conditionals" do
    tokens = [
      [:inverse_conditional_block_start, "bar?", nil, {}],
      [:component, "hello", nil, {}],
      [:else_block_start, "bar?", nil, {}],
      [:component, "bye", nil, {}],
      [:block_end, "bar?", nil],
    ]

    parse(tokens).should == [
      inverse_conditional_block(component("bar?"), [component("hello")], [component("bye")])
    ]
  end

  it "parses collection blocks" do
    tokens = [
      [:collection_block_start, "mice", nil, {}],
      [:component, "hello", nil, {}],
      [:block_end, "mice", nil],
    ]

    parse(tokens).should == [
      collection_block(component("mice"), [component("hello")])
    ]
  end

  it "fails if a block is not closed" do
    tokens = [
      [:collection_block_start, "mice", nil, {}],
    ]

    expect { parse(tokens) }.to raise_exception(Curly::IncompleteBlockError)
  end

  it "fails if a block is closed with the wrong component" do
    tokens = [
      [:collection_block_start, "mice", nil, {}],
      [:block_end, "men", nil, {}],
    ]

    expect { parse(tokens) }.to raise_exception(Curly::IncorrectEndingError)
  end

  it "fails if a conditional-type block is closed with the wrong component" do
    tokens = [
      [:inverse_conditional_block_start, "mice", nil, {}],
      [:conditional_block_end, nil, nil],
    ]

    expect { parse(tokens) }.to raise_exception(Curly::IncorrectEndingError)
  end

  it "fails if there is a closing component too many" do
    tokens = [
      [:block_end, "world", nil, {}],
    ]

    expect { parse(tokens) }.to raise_exception(Curly::IncorrectEndingError)
  end

  def parse(tokens)
    described_class.parse(tokens)
  end

  def component(*args)
    Curly::Parser::Component.new(*args)
  end

  def conditional_block(*args)
    Curly::Parser::Block.new(:conditional, *args)
  end

  def inverse_conditional_block(*args)
    Curly::Parser::Block.new(:inverse_conditional, *args)
  end

  def collection_block(*args)
    Curly::Parser::Block.new(:collection, *args)
  end
end
