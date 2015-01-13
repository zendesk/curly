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

module CompilationSupport
  def define_presenter(name = "ShowPresenter", &block)
    presenter_class = Class.new(Curly::Presenter, &block)
    stub_const(name, presenter_class)
    presenter_class
  end

  def render(source, locals = {}, presenter_class = nil, &block)
    if presenter_class.nil?
      unless defined?(ShowPresenter)
        define_presenter("ShowPresenter")
      end

      presenter_class = ShowPresenter
    end

    identifier = "show"
    handler = Curly::TemplateHandler
    details = { virtual_path: 'show' }
    template = ActionView::Template.new(source, identifier, handler, details)
    view = ActionView::Base.new

    begin
      template.render(view, locals, &block)
    rescue ActionView::Template::Error => e
      raise e.original_exception
    end
  end
end
