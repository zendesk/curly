require 'curly/dependency_tracker'

module Curly
  class Railtie < Rails::Railtie
    config.app_generators.template_engine :curly

    initializer 'curly.initialize_template_handler' do
      ActionView::Template.register_template_handler :curly, Curly::TemplateHandler

      if defined?(CacheDigests::DependencyTracker)
        CacheDigests::DependencyTracker.register_tracker :curly, Curly::DependencyTracker
      end

      if defined?(ActionView::DependencyTracker)
        ActionView::DependencyTracker.register_tracker :curly, Curly::DependencyTracker
      end
    end
  end
end
