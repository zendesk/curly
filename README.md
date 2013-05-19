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


Installing
----------

Installing Curly is as simple as running `gem install curly-templates`. If you're
using Bundler to manage your dependencies, add this to your Gemfile

```ruby
gem 'curly-templates'
```


How to use Curly
----------------

In order to use Curly for a view or partial, use the suffix `.curly` instead of
`.erb`, e.g. `app/views/posts/_comment.html.curly`. Curly will look for a
corresponding presenter class named `Posts::CommentPresenter`. By convention,
these are placed in `app/presenters/`, so in this case the presenter would
reside in `app/presenters/posts/comment_presenter.rb`. Note that presenters
for partials are not prepended with an underscore.

Add some HTML to the partial template along with some Curly variables:

```html
<!-- app/views/posts/_comment.html.curly -->
<div class="comment">
  <p>
    {{author_link}} posted {{time_ago}} ago.
  </p>

  {{body}}
</div>
```

The presenter will be responsible for filling in the variables. Add the necessary
Ruby code to the presenter:

```ruby
# app/presenters/posts/comment_presenter.rb
class Posts::CommentPresenter < Curly::Presenter
  presents :comment

  def body
    BlueCloth.new(@comment.body).to_html
  end

  def author_link
    link_to(@comment.author.name, @comment.author, rel: "author")
  end

  def time_ago
    time_ago_in_words(@comment.created_at)
  end
end
```

The partial can now be rendered like any other, e.g. by calling

```ruby
render 'comment', comment: comment
render comment
render collection: post.comments
```


Is it ready to use in production?
---------------------------------

Yes! While still a young project, it's being used in a rather large Rails app
at Zendesk, where it performs admirably.


Examples
--------

Here is a simple Curly template -- it will be looked up by Rails automatically.

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

When rendering the template, a presenter is automatically instantiated with the
variables assigned in the controller or the `render` call. The presenter declares
the variables it expects with `presents`, which takes a list of variables names.

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

Caching is handled at two levels in Curly – statically and dynamically. Static caching
concerns changes to your code and templates introduced by deploys. If you do not wish
to clear your entire cache every time you deploy, you need a way to indicate that some
view, helper, or other piece of logic has changed.

Dynamic caching concerns changes that happen on the fly, usually made by your users in
the running system. You wish to cache a view or a partial and have it expire whenever
some data is updated – usually whenever a specific record is changed.


### Dynamic Caching

Because of the way logic is contained in presenters, caching entire views or partials
by the data they present becomes exceedingly straightforward. Simply define a
`#cache_key` method that returns a non-nil object, and the return value will be used to
cache the template.

Whereas in ERB you would include the `cache` call in the template itself:

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


### Static Caching

Static caching will only be enabled for presenters that define a non-nil `#cache_key`
method (see "Dynamic Caching.")

In order to make a deploy expire the cache for a specific view, set the version of the
view to something new, usually by incrementing by one:

```ruby
class Posts::ShowPresenter < Curly::Presenter
  version 3

  def cache_key
    # Some objects
  end
end
```

This will change the cache keys for all instances of that view, effectively expiring
the old cache entries.

This works well for views, or for partials that are rendered in views that themselves
are not cached. If the partial is nested within a view that _is_ cached, however, the
outer cache will not be expired. The solution is to register that the inner partial
is a dependency of the outer one such that Curly can automatically deduce that the
outer partial cache should be expired:

```ruby
class Posts::ShowPresenter < Curly::Presenter
  version 3
  depends_on 'posts/comment'

  def cache_key
    # Some objects
  end
end

class Posts::CommentPresenter < Curly::Presenter
  version 4
  depends_on 'posts/comment'

  def cache_key
    # Some objects
  end
end
```

Now, if the version of `Posts::CommentPresenter` is bumped, the cache keys for both
presenters would change. You can register any number of view paths with `depends_on`.

If you use [Cache Digests](https://github.com/rails/cache_digests), Curly will
automatically provide a list of dependencies. This will allow you to deploy changes
to your templates and have the relevant caches automatically expire.


Thanks
------

Thanks to [Zendesk](http://zendesk.com/) for sponsoring the work on Curly.


Build Status
------------

[![Build Status](https://travis-ci.org/zendesk/curly.png?branch=master)](https://travis-ci.org/zendesk/curly)


Copyright and License
---------------------

Copyright (c) 2013 Daniel Schierbeck (@dasch), Zendesk Inc.

Licensed under the [Apache License Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
