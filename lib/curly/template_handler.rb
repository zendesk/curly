require 'active_support'
require 'action_view'
require 'curly'
require 'curly/compilation_error'

class Curly::TemplateHandler
  class << self

    # Handles a Curly template, compiling it to Ruby code. The code will be
    # evaluated in the context of an ActionView::Base instance, having access
    # to a number of variables.
    #
    # template - The ActionView::Template template that should be compiled.
    #
    # Returns a String containing the Ruby code representing the template.
    def call(template)
      instrument(template) do
        compile(template)
      end
    end

    private

    def compile(template)
      # Template is empty, so there's no need to initialize a presenter.
      return %("") if template.source.empty?

      path = template.virtual_path
      presenter_class = Curly::Presenter.presenter_for_path(path)

      raise Curly::CompilationError.new(path) if presenter_class.nil?

      source = Curly.compile(template.source, presenter_class)

      <<-RUBY
      if local_assigns.empty?
        options = assigns
      else
        options = local_assigns
      end

      presenter = #{presenter_class}.new(self, options.with_indifferent_access)

      view_function = lambda do
        #{source}
      end

      presenter.setup!

      if key = presenter.cache_key
        @output_buffer = ActiveSupport::SafeBuffer.new

        if #{presenter_class}.respond_to?(:cache_key)
          presenter_key = #{presenter_class}.cache_key
        else
          presenter_key = nil
        end

        options = {
          expires_in: presenter.cache_duration
        }

        cache([key, presenter_key].compact, options) do
          safe_concat(view_function.call)
        end

        @output_buffer
      else
        view_function.call.html_safe
      end
      RUBY
    end

    def instrument(template, &block)
      payload = { path: template.virtual_path }
      ActiveSupport::Notifications.instrument("compile.curly", payload, &block)
    end
  end
end
