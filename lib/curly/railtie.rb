module Curly
  class Railtie < Rails::Railtie
    config.app_generators.template_engine :curly

    initializer 'curly.initialize_template_handler' do
      ActionView::Template.register_template_handler :curly, Curly::TemplateHandler
    end
  end
end
