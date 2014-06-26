require 'rails/generators'
require 'rails/generators/named_base'

module Curly
  module Generators
    class ControllerGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../../templates", __FILE__)

      argument :actions, type: :array, default: [], banner: "action action"

      def create_view_files
        base_views_path = File.join("app/views", class_path, file_name)
        base_presenters_path = File.join("app/presenters", class_path, file_name)

        empty_directory base_views_path
        empty_directory base_presenters_path

        actions.each do |action|
          @view_path = File.join(base_views_path, "#{action}.html.curly")
          @presenter_path = File.join(base_presenters_path, "#{action}_presenter.rb")
          @action = action
          @assign = class_path.last.try(:singularize)
          @presenter_name = "#{class_name}::#{action.capitalize}Presenter"

          template "view.html.curly.erb", @view_path
          template "presenter.rb.erb", @presenter_path
        end
      end
    end
  end
end
