require 'rspec/expectations'
require 'nokogiri'

RSpec::Matchers.define(:have_structure) do |expected|
  match do |actual|
    normalized(actual).should == normalized(expected)
  end

  failure_message_for_should do |actual|
    "Expected\n\n#{actual}\n\n" \
      "to have the same structure as\n\n#{expected}"
  end

  failure_message_for_should_not do |actual|
    "Expected\n\n#{actual}\n\n" \
      "to NOT have the same canonicalized structure as\n\n#{expected}"
  end

  def normalized(text)
    document = Nokogiri::XML("<snippet>#{text}</snippet>")
    document.traverse do |node|
      node.content = node.text.strip if node.text?
    end

    document.canonicalize do |node, parent|
      !(node.text? && node.text.empty?)
    end
  end
end
