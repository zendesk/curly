### Unreleased

### Curly 2.6.3 (March 24, 2017)

* Added generator for Rails' built in scaffold command.
* Added `curly:install` generator for creating layout files.

  *Jack M*

### Curly 2.6.2 (December 22, 2016)

* Change `DependencyTracker.call` to returns array, for compatibility with
  Rails 5.0.

  *Benjamin Quorning*

### Curly 2.6.1 (August 3, 2016)

* Use Rails' `constantize` method instead of `get_const` when looking up
  presenter classes, so that Rails has a chance to autoload missing classes.

  *Creighton Long*

### Curly 2.6.0 (July 4, 2016)

* Add support for Rails 5.

* Add support for arbitrary component attributes. If the presenter method accepts
  arbitrary keyword arguments, the corresponding component is allowed to pass
  any attribute it wants.

  *Jeremy Rodi*

* Add support for testing presenters with RSpec:

  ```ruby\
  require 'curly/rspec'

  # spec/presenters/posts/show_presenter_spec.rb
  describe Posts::ShowPresenter, type: :presenter do
    describe "#body" do
      it "renders the post's body as Markdown" do
        assign(:post, double(:post, body: "**hello!**"))
        expect(presenter.body).to eq "<strong>hello!</strong>"
      end
    end
  end
  ```

  *Daniel Schierbeck*

### Curly 2.5.0 (May 19, 2015)

* Allow passing a block as the `default:` option to `presents`.

  ```ruby
  class CommentPresenter < Curly::Presenter
    presents :comment
    presents(:author) { @comment.author }
  end
  ```

  *Steven Davidovitz & Jeremy Rodi*

### Curly 2.4.0 (February 24, 2015)

* Add an `exposes_helper` class methods to Curly::Presenter. This allows exposing
  helper methods as components.

  *Jeremy Rodi*

* Add a shorthand syntax for using components within a context. This allows you
  to write `{{author:name}}` rather than `{{@author}}{{name}}{{/author}}`.

  *Daniel Schierbeck*

### Curly 2.3.2 (January 13, 2015)

* Fix an issue that caused presenter parameters to get mixed up.

  *Cristian Planas*

* Clean up the testing code.

  *Daniel Schierbeck*

### Curly 2.3.1 (January 7, 2015)

* Fix an issue with nested context blocks.

  *Daniel Schierbeck*

* Make `respond_to_missing?` work with presenter objects.

  *Jeremy Rodi*

### Curly 2.3.0 (December 22, 2014)

* Add support for Rails 4.2.

  *Łukasz Niemier*

* Allow spaces within components.

  *Łukasz Niemier*

### Curly 2.2.0 (December 4, 2014)

* Allow configuring arbitrary cache options.

  *Daniel Schierbeck*

### Curly 2.1.1 (November 12, 2014)

* Fix a bug where a parent presenter's parameters were not being passed to the
  child presenter when using context blocks.

  *Daniel Schierbeck*

### Curly 2.1.0 (November 6, 2014)

* Add support for [context blocks](https://github.com/zendesk/curly#context-blocks).

  *Daniel Schierbeck*

* Forward the parent presenter's parameters to the nested presenter when
  rendering collection blocks.

  *Daniel Schierbeck*

### Curly 2.0.1 (September 9, 2014)

* Fixed an issue when using Curly with Rails 4.1.

  *Daniel Schierbeck*

* Add line number information to syntax errors.

  *Jeremy Rodi*

### Curly 2.0.0 (July 1, 2014)

* Rename Curly::CompilationError to Curly::PresenterNotFound.

  *Daniel Schierbeck*

### Curly 2.0.0.beta1 (June 27, 2014)

* Add support for collection blocks.

  *Daniel Schierbeck*

* Add support for keyword parameters to references.

  *Alisson Cavalcante Agiani, Jeremy Rodi, and Daniel Schierbeck*

* Remove memory leak that could cause unbounded memory growth.

  *Daniel Schierbeck*

### Curly 1.0.0rc1 (February 18, 2014)

* Add support for conditional blocks:

  ```
  {{#admin?}}
    Hello!
  {{/admin?}}
  ```

  *Jeremy Rodi*

### Curly 0.12.0 (December 3, 2013)

* Allow Curly to output Curly syntax by using the `{{{ ... }}` syntax:

  ```
  {{{curly_example}}
  ```

  *Daniel Schierbeck and Benjamin Quorning*

### Curly 0.11.0 (July 31, 2013)

* Make Curly raise an exception when a reference or comment is not closed.

  *Daniel Schierbeck*

* Fix a bug that caused an infinite loop when there was whitespace in a reference.

  *Daniel Schierbeck*

### Curly 0.10.2 (July 11, 2013)

* Fix a bug that caused non-string presenter method return values to be
  discarded.

  *Daniel Schierbeck*

### Curly 0.10.1 (July 11, 2013)

* Fix a bug in the compiler that caused some templates to be erroneously HTML
  escaped.

  *Daniel Schierbeck*

### Curly 0.10.0 (July 11, 2013)

* Allow comments in Curly templates using the `{{! ... }}` syntax:

  ```
  {{! This is a comment }}
  ```

  *Daniel Schierbeck*

### Curly 0.9.1 (June 20, 2013)

* Better error handling. If a presenter class cannot be found, we not raise a
  more descriptive exception.

  *Daniel Schierbeck*

* Include the superclass' dependencies in a presenter's dependency list.

  *Daniel Schierbeck*

### Curly 0.9.0 (June 4, 2013)

* Allow running setup code before rendering a Curly view. Simply add a `#setup!`
  method to your presenter – it will be called by Curly just before the view is
  rendered.

  *Daniel Schierbeck*
