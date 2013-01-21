require 'active_support'
require 'action_view'
require 'curly'

class Curly::TemplateHandler
  def self.presenter_name_for_path(path)
    "#{path}_presenter".camelize
  end

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

      options = {
        expires_in: presenter.cache_duration
      }

      cache([template_digest, key], options) do
        safe_concat(view_function.call)
      end

      @output_buffer
    else
      view_function.call.html_safe
    end
    RUBY
  end
end

ActionView::Template.register_template_handler :curly, Curly::TemplateHandler
