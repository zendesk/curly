require 'curly/presenter_name_error'

module Curly

  # A base class that can be subclassed by concrete presenters.
  #
  # A Curly presenter is responsible for delivering data to templates, in the
  # form of simple strings. Each public instance method on the presenter class
  # can be referenced in a template. When a template is evaluated with a
  # presenter, the referenced methods will be called with no arguments, and
  # the returned strings inserted in place of the components in the template.
  #
  # Note that strings that are not HTML safe will be escaped.
  #
  # A presenter is always instantiated with a context to which it delegates
  # unknown messages, usually an instance of ActionView::Base provided by
  # Rails. See Curly::TemplateHandler for a typical use.
  #
  # Examples
  #
  #   class BlogPresenter < Curly::Presenter
  #     presents :post
  #
  #     def title
  #       @post.title
  #     end
  #
  #     def body
  #       markdown(@post.body)
  #     end
  #
  #     def author
  #       @post.author.full_name
  #     end
  #   end
  #
  #   presenter = BlogPresenter.new(context, post: post)
  #   presenter.author #=> "Jackie Chan"
  #
  class Presenter

    # Initializes the presenter with the given context and options.
    #
    # context - An ActionView::Base context.
    # options - A Hash of options given to the presenter.
    def initialize(context, options = {})
      @_context = context
      options.stringify_keys!

      self.class.presented_names.each do |name|
        value = options.fetch(name) do
          default_values.fetch(name) do
            block = default_blocks.fetch(name) do
              raise ArgumentError.new("required identifier `#{name}` missing")
            end

            instance_exec(name, &block)
          end
        end

        instance_variable_set("@#{name}", value)
      end
    end

    # Sets up the view.
    #
    # Override this method in your presenter in order to do setup before the
    # template is rendered. One use case is to call `content_for` in order
    # to inject content into other templates, e.g. a layout.
    #
    # Examples
    #
    #   class Posts::ShowPresenter < Curly::Presenter
    #     presents :post
    #
    #     def setup!
    #       content_for :page_title, @post.title
    #     end
    #   end
    #
    # Returns nothing.
    def setup!
      # Does nothing.
    end

    # The key that should be used to cache the view.
    #
    # Unless `#cache_key` returns nil, the result of rendering the template
    # that the presenter supports will be cached. The return value will be
    # part of the final cache key, along with a digest of the template itself.
    #
    # Any object can be used as a cache key, so long as it
    #
    # - is a String,
    # - responds to #cache_key itself, or
    # - is an Array or a Hash whose items themselves fit either of these
    #   criteria.
    #
    # Returns the cache key Object or nil if no caching should be performed.
    def cache_key
      nil
    end

    # The options that should be passed to the cache backend when caching the
    # view. The exact options may vary depending on the backend you're using.
    #
    # The most common option is `:expires_in`, which controls the duration of
    # time that the cached view should be considered fresh. Because it's so
    # common, you can set that option simply by defining `#cache_duration`.
    #
    # Note: if you set the `:expires_in` option through this method, the
    # `#cache_duration` value will be ignored.
    #
    # Returns a Hash.
    def cache_options
      {}
    end

    # The duration that the view should be cached for. Only relevant if
    # `#cache_key` returns a non nil value.
    #
    # If nil, the view will not have an expiration time set. See also
    # `#cache_options` for a more flexible way to set cache options.
    #
    # Examples
    #
    #   def cache_duration
    #     10.minutes
    #   end
    #
    # Returns the Fixnum duration of the cache item, in seconds, or nil if no
    #   duration should be set.
    def cache_duration
      nil
    end

    class << self

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
      def presenter_name_for_path(path)
        "#{path}_presenter".camelize
      end

      # Returns the presenter class for the given path.
      #
      # path - The String path of a template.
      #
      # Returns the Class or nil if the constant cannot be found.
      def presenter_for_path(path)
        begin
          # Assume that the path can be derived without a prefix; In other words
          # from the given path we can look up objects by namespace.
          presenter_for_name(path.camelize, [])
        rescue Curly::PresenterNameError
          nil
        end
      end

      # Retrieve the named presenter with consideration for object scope.
      # The namespace_prefixes are to acknowledge that sometimes we will have
      # a subclass of Curly::Presenter receiving the .presenter_for_name
      # and other times we will not (when we are receiving this message by
      # way of the .presenter_for_path method).
      def presenter_for_name(name, namespace_prefixes = to_s.split('::'))
        full_class_name = name.camelcase << "Presenter"
        relative_namespace = full_class_name.split("::")
        class_name = relative_namespace.pop
        namespace = namespace_prefixes + relative_namespace

        # Because Rails' autoloading mechanism doesn't work properly with
        # namespace we need to loop through the namespace ourselves. Ideally,
        # `X::Y.const_get("Z")` would autoload `X::Z`, but only `X::Y::Z` is
        # attempted by Rails. This sucks, and hopefully we can find a better
        # solution in the future.
        begin
          full_name = namespace.join("::") << "::" << class_name
          const_get(full_name)
        rescue NameError => e
          if namespace.empty?
            raise Curly::PresenterNameError.new(e, name)
          end
          namespace.pop
          retry
        end
      end

      # Whether a component is available to templates rendered with the
      # presenter.
      #
      # Templates have components which correspond with methods defined on
      # the presenter. By default, only public instance methods can be
      # referenced, and any method defined on Curly::Presenter itself cannot be
      # referenced. This means that methods such as `#cache_key` and #inspect
      # are not available. This is done for safety purposes.
      #
      # This policy can be changed by overriding this method in your presenters.
      #
      # name - The String name of the component.
      #
      # Returns true if the method can be referenced by a template,
      #   false otherwise.
      def component_available?(name)
        available_components.include?(name)
      end

      # A list of components available to templates rendered with the presenter.
      #
      # Returns an Array of String component names.
      def available_components
        @_available_components ||= begin
          methods = public_instance_methods - Curly::Presenter.public_instance_methods
          methods.map(&:to_s)
        end
      end

      # The set of view paths that the presenter depends on.
      #
      # Examples
      #
      #   class Posts::ShowPresenter < Curly::Presenter
      #     version 2
      #     depends_on 'posts/comment', 'posts/comment_form'
      #   end
      #
      #   Posts::ShowPresenter.dependencies
      #   #=> ['posts/comment', 'posts/comment_form']
      #
      # Returns a Set of String view paths.
      def dependencies
        # The base presenter doesn't have any dependencies.
        return SortedSet.new if self == Curly::Presenter

        @dependencies ||= SortedSet.new
        @dependencies.union(superclass.dependencies)
      end

      # Indicate that the presenter depends a list of other views.
      #
      # deps - A list of String view paths that the presenter depends on.
      #
      # Returns nothing.
      def depends_on(*dependencies)
        @dependencies ||= SortedSet.new
        @dependencies.merge(dependencies)
      end

      # Get or set the version of the presenter.
      #
      # version - The Integer version that should be set. If nil, no version
      #           is set.
      #
      # Returns the current Integer version of the presenter.
      def version(version = nil)
        @version = version if version.present?
        @version || 0
      end

      # The cache key for the presenter class. Includes all dependencies as
      # well.
      #
      # Returns a String cache key.
      def cache_key
        @cache_key ||= compute_cache_key
      end

      private

      def compute_cache_key
        dependency_cache_keys = dependencies.map do |path|
          if presenter = presenter_for_path(path)
            presenter.cache_key
          else
            path
          end
        end

        [name, version, dependency_cache_keys].flatten.join("/")
      end

      def presents(*args, **options, &block)
        if options.key?(:default) && block_given?
          raise ArgumentError,  "Cannot provide both `default:` and block"
        end

        self.presented_names += args.map(&:to_s)

        args.each do |arg|
          define_method arg do
            instance_variable_get("@#{arg}")
          end
          protected arg
        end

        if options.key?(:default)
          args.each do |arg|
            self.default_values = default_values.merge(arg.to_s => options[:default]).freeze
          end
        end

        if block_given?
          args.each do |arg|
            self.default_blocks = default_blocks.merge(arg.to_s => block).freeze
          end
        end
      end

      def exposes_helper(*methods)
        methods.each do |method_name|
          define_method(method_name) do |*args|
            @_context.public_send(method_name, *args)
          end
        end
      end

      alias_method :exposes_helpers, :exposes_helper
    end

    private

    class_attribute :presented_names, :default_values, :default_blocks

    self.presented_names = [].freeze
    self.default_values = {}.freeze
    self.default_blocks = {}.freeze

    delegate :render, to: :@_context

    # Delegates private method calls to the current view context.
    #
    # The view context, an instance of ActionView::Base, is set by Rails.
    def method_missing(method, *args, &block)
      @_context.public_send(method, *args, &block)
    end

    # Tells ruby (and developers) what methods we can accept.
    def respond_to_missing?(method, include_private = false)
      @_context.respond_to?(method, false)
    end
  end
end
