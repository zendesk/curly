### Unreleased

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
