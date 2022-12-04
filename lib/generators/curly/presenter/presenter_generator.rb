require 'rails/generators'
require 'rails/generators/named_base'

module Curly
  module Generators
    class PresenterGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../../templates', __FILE__)

      desc "Creates a presenter class for the given view path."
      def generate_presenter
        @presenter_name = "#{presenter_namespace}::#{file_name.capitalize}Presenter"
        @assign = class_path.last.singularize

        empty_directory base_presenters_path
        template "presenter.rb.erb", presenter_path
      end

      private

      def presenter_path
        File.join(base_presenters_path, "#{file_name}_presenter.rb")
      end

      def base_presenters_path
        File.join("app/presenters", class_path)
      end

      def presenter_namespace
        class_path.map { |m| m.camelize }.join('::')
      end
    end
  end
end
