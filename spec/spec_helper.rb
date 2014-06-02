require 'active_support/all'

if ENV['CI']
  begin
    require 'coveralls'
    Coveralls.wear!
  rescue LoadError
    STDERR.puts "Failed to load Coveralls"
  end
end

require 'curly'

module CompilationSupport
  def evaluate(template, options = {}, &block)
    code = Curly::Compiler.compile(template, presenter_class)
    context = double("context")

    context.instance_eval(<<-RUBY)
      def self.render(presenter, options)
        #{code}
      end
    RUBY

    context.render(presenter, options, &block)
  end
end
