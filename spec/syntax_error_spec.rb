describe Curly::SyntaxError, "#message" do
  it "includes the context of the error in the message" do
    source = "I am a very bad error that has snuck in"
    error = Curly::SyntaxError.new(13, source)

    error.message.should == <<-MESSAGE.strip_heredoc
      invalid syntax near `a very bad error` on line 1 in template:

      I am a very bad error that has snuck in
    MESSAGE
  end
end
