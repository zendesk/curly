### Unreleased

* Better error handling. If a presenter class cannot be found, we not raise a
  more descriptive exception.

  *Daniel Schierbeck*

### Curly 0.9.0 (June 4, 2013)

* Allow running setup code before rendering a Curly view. Simply add a `#setup!`
  method to your presenter – it will be called by Curly just before the view is
  rendered.

  *Daniel Schierbeck*
