### Unreleased

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
