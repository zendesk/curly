describe Curly::Lexer, ".lex" do
  it 'is an RLTK lexer' do
    subject.should be_a(RLTK::Lexer)
  end

  it "returns the tokens in the source" do
    map_lex_type("foo {{bar}} baz").should == [
      :OUT, :EXPRST, :IDENT, :EXPRE, :OUT, :EOS
    ]
  end

  it "scans components with identifiers" do
    map_lex_type("{{foo.bar}}").should == [
      :EXPRST, :IDENT, :EXPRE, :EOS
    ]
  end

  it "scans comments in the source" do
    map_lex_type("foo {{!bar}} baz").should == [
      :OUT, :EXPRST, :BANG, :COMMENT, :EXPRE, :OUT, :EOS
    ]
  end

  it "allows newlines in comments" do
    map_lex_type("{{!\nfoo\n}}").should == [
      :EXPRST, :BANG, :COMMENT, :EXPRE, :EOS
    ]
  end

  it "scans to the end of the source" do
    map_lex_type("foo\n").should == [:OUT, :EOS]
  end

  it "scans conditional block tags with the if syntax" do
    map_lex_type('foo {{#if bar?}} hello {{/if}}').should == [
      :OUT, :EXPRST, :IF, :WHITE, :IDENT, :EXPRE,
      :OUT, :EXPRST, :IFCLOSE, :EXPRE, :EOS
    ]
  end

  it "scans conditional block tags with the else token" do
    map_lex_type('foo {{#if bar?}} hello {{else}} bye {{/if}}').should == [
      :OUT, :EXPRST, :IF, :WHITE, :IDENT, :EXPRE,
      :OUT, :EXPRST, :ELSE, :EXPRE,
      :OUT, :EXPRST, :IFCLOSE, :EXPRE, :EOS
    ]
  end

  it "scans inverse block tags using the unless syntax" do
    map_lex_type('foo {{#unless bar?}} hello {{/unless}}').should == [
      :OUT, :EXPRST, :UNLESS, :WHITE, :IDENT, :EXPRE,
      :OUT, :EXPRST, :UNLESSCLOSE, :EXPRE, :EOS
    ]
  end

  it "scans inverse conditional block tags with the else token" do
    map_lex_type('foo {{#unless bar?}} hello {{else}} bye {{/unless}}').should == [
      :OUT, :EXPRST, :UNLESS, :WHITE, :IDENT, :EXPRE,
      :OUT, :EXPRST, :ELSE, :EXPRE,
      :OUT, :EXPRST, :UNLESSCLOSE, :EXPRE, :EOS
    ]
  end

  it "scans collection block tags with the each syntax" do
    map_lex_type('foo {{#each bar}} hello {{/each}}').should == [
      :OUT, :EXPRST, :EACH, :WHITE, :IDENT, :EXPRE,
      :OUT, :EXPRST, :EACHCLOSE, :EXPRE, :EOS
    ]
  end

  it "treats quotes as text" do
    map_lex_type('"').should == [:OUT, :EOS]
  end

  it "treats Ruby interpolation as text" do
    map_lex_type('#{foo}').should == [:OUT, :EOS]
  end

  def lex(source)
    Curly::Lexer.lex(source)
  end

  def map_lex_type(source)
    lex(source).map(&:type)
  end
end
