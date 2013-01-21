Curly
=======

Free your views!

Curly is a template language that completely separates structure and logic.
Instead of interspersing your HTML with snippets of Ruby, all logic is moved
to a presenter class, with only simple placeholders in the HTML.

While the basic concepts are very similar to [Mustache](http://mustache.github.com/)
or [Handlebars](http://handlebarsjs.com/), Curly is different in some key ways:

- Instead of the template controlling the variable scope and looping through
  data, all logic is left to the presenter object. This means that untrusted
  templates can safely be executed, making Curly a possible alternative to
  languages like [Liquid](http://liquidmarkup.org/).
- Instead of implementing its own template resolution mechanism, Curly hooks
  directly into Rails, leveraging the existing resolvers.
- Because of the way it integrates with Rails, it is very easy to use partial
  Curly templates to split out logic from a presenter. With Mustache, at least,
  when integrating with Rails, it is common to return Hash objects from view
  object methods that are in turn used by the template.


Examples
--------

```html
<!-- app/views/posts/show.html.curly -->
<h1>{{title}}<h1>
<p class="author">{{author}}</p>
<p>{{description}}</p>

{{comment_form}}

<div class="comments">
  {{comments}}
</div>
```

```ruby
# app/presenters/posts/show_presenter.rb
class Posts::ShowPresenter < Curly::Presenter
  presents :post

  def title
    @post.title
  end

  def author
    link_to(@post.author.name, @post.author, rel: "author")
  end

  def description
    Markdown.new(@post.description).to_html.html_safe
  end

  def comments
    render 'comment', collection: @post.comments
  end

  def comment_form
    if @post.comments_allowed?
      render 'comment_form', post: @post
    else
      content_tag(:p, "Comments are disabled for this post")
    end
  end
end
```


Caching
-------

Because of the way logic is contained in presenters, caching entire views or partials
becomes exceedingly straightforward. Simply define a `#cache_key` method that returns
a non-nil object, and the return value will be used to cache the template.

Whereas in ERB your would include the `cache` call in the template itself:

```erb
<% cache([@post, signed_in?]) do %>
  ...
<% end %>
```

In Curly you would instead declare it in the presenter:

```ruby
class Posts::ShowPresenter < Curly::Presenter
  presents :post

  def cache_key
    [@post, signed_in?]
  end
end
```

Likewise, you can add a `#cache_duration` method if you wish to automatically expire
the fragment cache:

```ruby
class Posts::ShowPresenter < Curly::Presenter
  ...

  def cache_duration
    30.minutes
  end
end
```


Copyright and License
---------------------

Copyright (c) 2013 Daniel Schierbeck (@dasch), Zendesk Inc.

Licensed under the [Apache License Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
