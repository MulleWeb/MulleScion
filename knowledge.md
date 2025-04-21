## Testing Guidelines

This project uses [mulle-test](https://github.com/mulle-sde/mulle-test) to run
tests. You create the test library with `mulle-sde test craft` and then run all
tests with `mulle-sde test run` or individual tests with
`mulle-sde test run <test.m>`

### Test Organization

- Create separate .m files for each method or feature being tested
- Name test files descriptively: `<class>-<method>.m`
- Include matching .stdout files with expected output
- Keep tests focused and minimal
- Group related classes into logical test files (e.g., all terminators in one file)

### Test Style

- Use mulle_printf to produce output for verification
- Compare output with .stdout files rather than using assertions
- Test both normal operation and edge cases
- Always include nil handling tests
- Maintain proper non-ARC memory management (retain/autorelease)
- Test output should be clear and descriptive and stable across platforms and runs

### Memory Management Tests

- Every class in MulleScionObjectModel.h needs a leak test
- Never instantiate abstract classes directly (e.g., MulleScionExpression)
- Use concrete subclasses for testing:
  - For expressions: MulleScionNumber, MulleScionString, MulleScionVariable
  - For arrays: Use @[] literal syntax for test data
  - For dictionaries: Use @{} literal syntax for test data
- Methods with NS_CONSUMED annotations take ownership of their parameters:
  - Don't autorelease parameters passed to these methods
  - The method will handle releasing the objects
- Methods without NS_CONSUMED do not take ownership:
  - Autorelease parameters passed to these methods
  - The caller is responsible for releasing the objects
- +new methods return objects with +1 retain count:
  - Always autorelease objects returned from +new methods
  - Use @autoreleasepool for test methods
- Test memory management patterns:
  - Single object creation/destruction
  - Object hierarchies (parent/child relationships)
  - Collections of objects
  - Object references and cycles

### Leak Test File Structure

- Use @autoreleasepool in each test function
- Wrap test code in @try/@catch to handle exceptions
- Include standard headers and imports
- Follow the pattern:
  ```objc
  static void test_ClassName_noleak(void)
  {
      @autoreleasepool
      {
          @try
          {
              // Test code here
          }
          @catch(NSException *localException)
          {
              fprintf(stderr, "Threw a %s exception\n",
                     [[localException name] UTF8String]);
              _exit(1);
          }
      }
  }
  ```
