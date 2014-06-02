# weeeee.... we're going to break curly!

require 'active_support/all'
require 'curly'

str = []

1_000_000.times do |i|
  str << "{{#{'x' * 100}#{i}}}"
end


class Presenter
  def self.method_available?(_)
    false
  end

  def self.available_methods
    []
  end
end

# I'm gonna borrow this from the spec...
def evaluate(template, &block)
  code = Curly::Compiler.compile(template, Presenter)
  context = double("context", presenter: Presenter.new)

  context.instance_eval(<<-RUBY)
    def self.render
      #{code}
    end
  RUBY

  context.render(&block)
end

1_000_000.times do |i|
  begin
    evaluate(str[i])
  rescue; end
end

