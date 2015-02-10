describe Curly::HbsParser do
  it "parses a text" do
    lex = Curly::Lexer.lex("a")

    subject.parse(lex).should == [text("a")]
  end

  it "parses comments" do
    lex = Curly::Lexer.lex("{{!foo}}")

    subject.parse(lex).should == [comment("foo")]
  end

  it "parses component tokens" do
    lex = Curly::Lexer.lex("{{a}}")

    subject.parse(lex).should == [component("a")]
  end

  it "parses conditionals blocks" do
    lex = Curly::Lexer.lex("{{#if a}}b{{/if}}")

    subject.parse(lex).should == [conditional_block(component("a"), [text("b")])]
  end

  it "parses conditionals blocks with elses" do
    lex = Curly::Lexer.lex("{{#if a}}b{{else}}c{{/if}}")

    subject.parse(lex).should == [conditional_block(component("a"), [text("b")], [text("c")])]
  end

  it "parses reverse conditional blocks" do
    lex = Curly::Lexer.lex("{{#unless a}}b{{/unless}}")

    subject.parse(lex).should == [inverse_conditional_block(component("a"), [text("b")])]
  end

  it "parses reverse conditional blocks with elses" do
    lex = Curly::Lexer.lex("{{#unless a}}b{{else}}c{{/unless}}")

    subject.parse(lex).should == [inverse_conditional_block(component("a"), [text("b")], [text("c")])]
  end

  it "parses collection blocks" do
    lex = Curly::Lexer.lex("{{#each a}}b{{/each}}")

    subject.parse(lex).should == [collection_block(component("a"), [text("b")])]
  end

  it "parses collection blocks with elses" do
    lex = Curly::Lexer.lex("{{#each a}}b{{else}}c{{/each}}")

    subject.parse(lex).should == [collection_block(component("a"), [text("b")], [text("c")])]
  end

  it "parses context blocks with with syntax" do
    lex = Curly::Lexer.lex("{{#with a}}b{{/with}}")

    subject.parse(lex).should == [context_block(component("a"), [text("b")])]
  end

  it "parses context blocks with with syntax and dots" do
    lex = Curly::Lexer.lex("{{#with a.b}}c{{/with}}")

    subject.parse(lex).should == [context_block(component("a", "b"), [text("c")])]
  end

  def parse(template)
    described_class.parse(Curly::Lexer.lex(template))
  end

  def component(*args)
    Curly::HbsParser::Component.new(*args)
  end

  def text(content)
    Curly::HbsParser::Text.new(content)
  end

  def conditional_block(*args)
    Curly::HbsParser::Block.new(:conditional, *args)
  end

  def inverse_conditional_block(*args)
    Curly::HbsParser::Block.new(:inverse_conditional, *args)
  end

  def collection_block(*args)
    Curly::HbsParser::Block.new(:collection, *args)
  end

  def context_block(*args)
    Curly::HbsParser::Block.new(:context, *args)
  end

  def comment(content)
    Curly::HbsParser::Comment.new(content)
  end
end
