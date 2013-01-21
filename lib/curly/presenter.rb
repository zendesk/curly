module Curly

  # A base class that can be subclassed by concrete presenters.
  #
  # A Curly presenter is responsible for delivering data to templates, in the
  # form of simple strings. Each public instance method on the presenter class
  # can be referenced in a template. When a template is evaluated with a
  # presenter, the referenced methods will be called with no arguments, and
  # the returned strings inserted in place of the references in the template.
  #
  # Note that strings that are not HTML safe will be escaped.
  #
  # A presenter is always instantiated with a context to which it delegates
  # unknown messages, usually an instance of ActionView::Base provided by
  # Rails. See Curly::Handler for a typical use.
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
    RESERVED_METHODS = [
      :cache_key,
      :cache_duration,
      :presented_names,
      :presented_names=,
      :presented_names?
    ]

    # Initializes the presenter with the given context and options.
    #
    # context - An ActionView::Base context.
    # options - A Hash of options given to the presenter.
    #
    def initialize(context, options = {})
      @_context = context
      self.class.presented_names.each do |name|
        instance_variable_set("@#{name}", options.fetch(name))
      end
    end

    def cache_key
      nil
    end

    def cache_duration
      nil
    end

    def self.available_components
      excluded_methods = Object.public_instance_methods + RESERVED_METHODS
      public_instance_methods - excluded_methods
    end

    private

    class_attribute :presented_names
    self.presented_names = [].freeze

    def self.presents(*args)
      self.presented_names += args
    end

    def method_missing(method, *args, &block)
      @_context.public_send(method, *args, &block)
    end
  end
end
