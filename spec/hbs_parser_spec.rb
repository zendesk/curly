describe Curly::HbsParser do
  it "parses a text" do
    lex = Curly::Lexer.lex("a")

    subject.parse(lex).should == [text("a")]
  end

  it "parses component tokens" do
    lex = Curly::Lexer.lex("{{a}}")

    subject.parse(lex).should == [component("a")]
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
end
