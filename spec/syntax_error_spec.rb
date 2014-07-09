require 'spec_helper'

describe Curly::SyntaxError, "#message" do
  it "includes the context of the error in the message" do
    source = "I am a very bad error that has snuck in"
    error = Curly::SyntaxError.new(13, source, 3)

    error.message.should == <<-MESSAGE.strip_heredoc
      invalid syntax near `a very bad error` on line 3 in template:

      I am a very bad error that has snuck in
    MESSAGE
  end
end
