require 'active_support'
require 'action_view'
require 'curly'
require 'curly/presenter_not_found'

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

    def cache_if_key_is_not_nil(context, presenter)
      if key = presenter.cache_key
        if presenter.class.respond_to?(:cache_key)
          presenter_key = presenter.class.cache_key
        else
          presenter_key = nil
        end

        cache_options = presenter.cache_options || {}
        cache_options[:expires_in] ||= presenter.cache_duration
        controller = context.controller
        fragment_name = context.cache_fragment_name([key, presenter_key].compact, cache_options)
        fragment = controller.read_fragment(fragment_name, cache_options)

        if fragment.nil?
          fragment = yield
          controller.write_fragment(fragment_name, fragment, cache_options)
        end

        fragment
      else
        yield
      end
    end

    private

    def compile(template)
      # Template is empty, so there's no need to initialize a presenter.
      return %("") if template.source.empty?

      path = template.virtual_path
      presenter_class = Curly::Presenter.presenter_for_path(path)

      raise Curly::PresenterNotFound.new(path) if presenter_class.nil?

      source = Curly.compile(template.source, presenter_class)

      <<-RUBY
      if local_assigns.empty?
        options = assigns
      else
        options = local_assigns
      end

      presenter = ::#{presenter_class}.new(self, options)
      presenter.setup!

      @output_buffer = output_buffer || ActiveSupport::SafeBuffer.new

      Curly::TemplateHandler.cache_if_key_is_not_nil(self, presenter) do
        result = #{source}
        safe_concat(result)
      end

      @output_buffer
      RUBY
    end

    def instrument(template, &block)
      payload = { path: template.virtual_path }
      ActiveSupport::Notifications.instrument("compile.curly", payload, &block)
    end
  end
end
