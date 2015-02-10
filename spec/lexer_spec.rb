describe Curly::Lexer, ".lex" do
  it 'is an RLTK lexer' do
    subject.should be_a(RLTK::Lexer)
  end

  it "returns the tokens in the source" do
    map_lex_type("foo {{bar}} baz").should == [
      :OUT, :CURLYSTART, :IDENT, :CURLYEND, :OUT, :EOS
    ]
  end

  it "scans components with identifiers" do
    map_lex_type("{{foo.bar}}").should == [
      :CURLYSTART, :IDENT, :CURLYEND, :EOS
    ]
  end

  it "scans comments in the source" do
    map_lex_type("foo {{!bar}} baz").should == [
      :OUT, :CURLYSTART, :BANG, :COMMENT, :CURLYEND, :OUT, :EOS
    ]
  end

  it "allows newlines in comments" do
    map_lex_type("{{!\nfoo\n}}").should == [
      :CURLYSTART, :BANG, :COMMENT, :CURLYEND, :EOS
    ]
  end

  it "scans to the end of the source" do
    map_lex_type("foo\n").should == [:OUT, :EOS]
  end

  it "scans context block tags with the with syntax" do
    map_lex_type('{{#with bar}} hello {{/with}}').should == [
      :CURLYSTART, :WITH, :IDENT, :CURLYEND,
      :OUT, :CURLYSTART, :WITHCLOSE, :CURLYEND, :EOS
    ]
  end

  it "scans conditional block tags with the if syntax" do
    map_lex_type('foo {{#if bar?}} hello {{/if}}').should == [
      :OUT, :CURLYSTART, :IF, :IDENT, :CURLYEND,
      :OUT, :CURLYSTART, :IFCLOSE, :CURLYEND, :EOS
    ]
  end

  it "scans conditional block tags with the else token" do
    map_lex_type('foo {{#if bar?}} hello {{else}} bye {{/if}}').should == [
      :OUT, :CURLYSTART, :IF, :IDENT, :CURLYEND,
      :OUT, :CURLYSTART, :ELSE, :CURLYEND,
      :OUT, :CURLYSTART, :IFCLOSE, :CURLYEND, :EOS
    ]
  end

  it "scans inverse block tags using the unless syntax" do
    map_lex_type('foo {{#unless bar?}} hello {{/unless}}').should == [
      :OUT, :CURLYSTART, :UNLESS, :IDENT, :CURLYEND,
      :OUT, :CURLYSTART, :UNLESSCLOSE, :CURLYEND, :EOS
    ]
  end

  it "scans inverse conditional block tags with the else token" do
    map_lex_type('foo {{#unless bar?}} hello {{else}} bye {{/unless}}').should == [
      :OUT, :CURLYSTART, :UNLESS, :IDENT, :CURLYEND,
      :OUT, :CURLYSTART, :ELSE, :CURLYEND,
      :OUT, :CURLYSTART, :UNLESSCLOSE, :CURLYEND, :EOS
    ]
  end

  it "scans collection block tags with the each syntax" do
    map_lex_type('foo {{#each bar}} hello {{/each}}').should == [
      :OUT, :CURLYSTART, :EACH, :IDENT, :CURLYEND,
      :OUT, :CURLYSTART, :EACHCLOSE, :CURLYEND, :EOS
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
