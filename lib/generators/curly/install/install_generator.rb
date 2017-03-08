require "rails/generators/resource_helpers"

module Curly # :nodoc:
  module Generators # :nodoc:
    class InstallGenerator < Rails::Generators::Base # :nodoc:

      source_root File.expand_path("../templates", __FILE__)

      attr_reader :app_name

      def generate_layout
        app = ::Rails.application
        @app_name = app.class.to_s.split("::").first
        remove_file 'app/views/layouts/application.html.erb'
        template "layout.html.curly.erb", "app/views/layouts/application.html.curly"
        template "layout_presenter.rb.erb", "app/presenters/layouts/application_presenter.rb"
      end

    end
  end
end