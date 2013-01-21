module Curly
  class Railtie < Rails::Railtie
    initializer 'curly.initialize_template_handler' do
      require 'curly/template_handler'
      ActionView::Template.register_template_handler :curly, Curly::TemplateHandler
    end
  end
end
