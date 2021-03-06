require "rails/generators/resource_helpers"
require "generators/curly"

module Curly # :nodoc:
  module Generators # :nodoc:
    class ScaffoldGenerator < Base # :nodoc:
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path("../templates", __FILE__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def create_root_folder
        empty_directory File.join("app/views", controller_file_path)
        empty_directory File.join("app/presenters", controller_file_path)
      end

      def copy_view_files
        available_views.each do |view|
          # Useful in the presenters.
          @view_name = presenter_view(view)
          # Example:  posts/index.html.curly
          view_file = "#{view}.#{format}.curly"
          template "#{view_file}.erb", File.join("app/views", controller_file_path, view_file)
          # Example: posts/index_presenter.rb
          presenter_file = "#{@view_name}_presenter.rb"
          template "#{presenter_file}.erb", File.join("app/presenters", controller_file_path, presenter_file)
        end
      end

    private

      # Hack for _form view.
      def presenter_view(view)
        view.gsub(/^_/, '')
      end

      def available_views
        %w(index show edit _form new)
      end
    end
  end
end