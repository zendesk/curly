ENV["RAILS_ENV"] = "test"

require 'dummy/config/environment'
require 'rspec/rails'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end

module CompilationSupport
  def define_presenter(name = "ShowPresenter", &block)
    presenter_class = Class.new(Curly::Presenter, &block)
    stub_const(name, presenter_class)
    presenter_class
  end

  def render(source, options = {}, &block)
    presenter = options.fetch(:presenter) do
      define_presenter("ShowPresenter") unless defined?(ShowPresenter)
      "ShowPresenter"
    end.constantize

    virtual_path = options.fetch(:virtual_path) do
      presenter.name.underscore.gsub(/_presenter\z/, "")
    end

    identifier = options.fetch(:identifier) do
      defined?(Rails.root) ? "#{Rails.root}/#{virtual_path}.html.curly" : virtual_path
    end

    details = { virtual_path: virtual_path }
    details.merge! options.fetch(:details, {})

    handler = Curly::TemplateHandler
    template = ActionView::Template.new(source, identifier, handler, details)
    view = ActionView::Base.new
    view.lookup_context.stub(:find_template) { source }

    begin
      template.render(view, options.fetch(:locals, {}), &block)
    rescue ActionView::Template::Error => e
      raise e.original_exception
    end
  end
end
