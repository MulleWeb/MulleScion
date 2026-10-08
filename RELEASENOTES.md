### 1862.0.3


* Document that the caching category stays declared even when caching is
  disabled, with only its methods conditionally compiled out, so the reflected
  class/category dependency remains satisfiable on every platform
* Explain that the ``DONT_HAVE_MULLE_SCION_CACHING`` guard tests the value of
  ``TARGET_OS_IPHONE`` (defined as `0` on macOS, `1` on iOS) rather than its mere
  existence
* Update the API currency note to reflect reworked conditional compilation and
  dependency version bounds



feature: support variadic method calls and fix char * handling in templates

* call variadic methods (e.g. `stringByAppendingFormat:`) from templates; arguments after the named parameters become the variadic tail
* variadic tail arguments are objects only — `int`/`long`/`double` tails are not supported, since a template cannot specify variadic argument types
* an `NSString` can now be passed where a `char *` argument is expected
* methods returning a `char *` now print the characters instead of the pointer
* fix a Windows build break caused by `mingw` ``<io.h>`` declaring `eof`

### 1862.0.2



* standardize source file headers to a consistent BSD license notice
* remove dated "Created by" authorship lines from .h and .m files
* add missing copyright and redistribution boilerplate to public headers
* correct file description in header comments (e.g. MulleScionLocals, exists)

### 1862.0.1

Various small improvements
