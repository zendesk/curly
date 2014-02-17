In order to keep the Curly code base nice and tidy, please observe these best practises when making contributions:

- Add tests for all your code. Make sure the tests are clear and fail with proper error messages. It's a good idea to let your test fail in order to review whether the message makes sense; then make the test pass.
- Document any unclear things in the code. Even better, don't make the code do unclear things.
- Use the coding style already present in the code base.
- Make your commit messages precise and to the point. Add a short summary (50 chars max) followed by a blank line and then a longer description, if necessary, e.g.
  > Make invalid references raise an exception
  >
  > In order to avoid nasty errors when doing stuff, make the Curly compiler
  > fail early when an invalid reference is encountered.

Before making a contribution, you should make sure to understand what Curly is and isn't:

- The template language will never be super advanced: one of the primary use cases for Curly is to allow end users to mess around with Curly templates and have them safely compiled and rendered on a server. As such, the template language will always be as simple as possible.
- The template language is declarative, and is going to stay that way.
