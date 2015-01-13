ENV["RAILS_ENV"] = "test"

require 'dummy/config/environment'
require 'rspec/rails'

if ENV['CI']
  begin
    require 'coveralls'
    Coveralls.wear!
  rescue LoadError
    STDERR.puts "Failed to load Coveralls"
  end
end

module RenderingSupport
  def presenter(&block)
    @presenter = block
  end

  def render(source)
    stub_const("TestPresenter", Class.new(Curly::Presenter, &@presenter))
    identifier = "test"
    handler = Curly::TemplateHandler
    details = { virtual_path: 'test' }
    template = ActionView::Template.new(source, identifier, handler, details)
    locals = {}
    view = ActionView::Base.new

    template.render(view, locals)
  end
end

module CompilationSupport
  def define_presenter(name, &block)
    stub_const(name, Class.new(Curly::Presenter, &block))
  end

  def evaluate(template, options = {}, &block)
    code = Curly::Compiler.compile(template, presenter.class)
    context = double("context")

    context.instance_eval(<<-RUBY)
      def self.render(presenter, options)
        #{code}
      end
    RUBY

    context.render(presenter, options, &block)
  end
end
