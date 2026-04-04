### 1861.2.2










* Add `MULLE_C_UNUSED` annotations to eliminate unused-parameter compiler warnings across multiple src/*.m files, improving build cleanliness and compiler output.
* Relax minimum foundation-version check in reflect header `(MULLE_OBJC_INET_OS_FOUNDATION_VERSION_MIN)` to avoid unnecessary build failures on some toolchains.



* Convert expression parser to Pratt precedence climbing algorithm
* Add `parser_get_binary_precedence()` with C precedence levels
* Add `parser_is_right_associative()` for ternary conditional
* Use parser memo/recall to handle precedence-based operator rejection
* Remove overly strict parenthesis check for conditional right side
* Comment out and/or parenthesis checks (now handled by precedence)
* Add AI analysis documentation in dox/ai-analysis/
