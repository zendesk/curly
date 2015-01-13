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
  def define_presenter(name = "ShowPresenter", &block)
    presenter_class = Class.new(Curly::Presenter, &block)
    stub_const(name, presenter_class)
    presenter_class
  end

  def render(template, options = {}, presenter_class = nil, &block)
    if presenter_class.nil?
      unless defined?(ShowPresenter)
        define_presenter("ShowPresenter")
      end

      presenter_class = ShowPresenter
    end

    code = Curly::Compiler.compile(template, presenter_class)
    context = double("context")

    context.instance_eval(<<-RUBY)
      def self.render(presenter, options)
        #{code}
      end
    RUBY

    presenter = presenter_class.new(context, options)
    context.render(presenter, options, &block)
  end
end
