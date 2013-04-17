require 'active_support'
require 'action_view'
require 'curly'

class Curly::TemplateHandler

  # The name of the presenter class for a given view path.
  #
  # path - The String path of a view.
  #
  # Examples
  #
  #   Curly::TemplateHandler.presenter_name_for_path("foo/bar")
  #   #=> "Foo::BarPresenter"
  #
  # Returns the String name of the matching presenter class.
  def self.presenter_name_for_path(path)
    "#{path}_presenter".camelize
  end

  def self.presenter_for_path(path)
    presenter_name_for_path(path).constantize
  end

  # Handles a Curly template, compiling it to Ruby code. The code will be
  # evaluated in the context of an ActionView::Base instance, having access
  # to a number of variables.
  #
  # template - The ActionView::Template template that should be compiled.
  #
  # Returns a String containing the Ruby code representing the template.
  def self.call(template)
    presenter_class = presenter_name_for_path(template.virtual_path)

    source = Curly.compile(template.source)
    template_digest = Digest::MD5.hexdigest(template.source)

    # Template is empty, so there's no need to initialize a presenter.
    return %("") if template.source.empty?

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

    if key = presenter.cache_key
      @output_buffer = ActiveSupport::SafeBuffer.new

      template_digest = #{template_digest.inspect}

      if #{presenter_class}.respond_to?(:cache_key)
        presenter_key = #{presenter_class}.cache_key
      else
        presenter_key = nil
      end

      options = {
        expires_in: presenter.cache_duration
      }

      cache([template_digest, key, presenter_key].compact, options) do
        safe_concat(view_function.call)
      end

      @output_buffer
    else
      view_function.call.html_safe
    end
    RUBY
  end
end
