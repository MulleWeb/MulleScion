# MulleScion Library Documentation for AI
<!-- Keywords: template, engine, objectivec, parser, rendering, twig, kvc -->

## 1. Introduction & Purpose

**MulleScion** is a template engine for Objective-C, inspired by Django/Twig
templates (very similar to TWIG). It parses a template (HTML or text) and
renders it against a *data source* object, substituting variables, calling
Objective-C methods, iterating collections (`for`/`while`), branching (`if`),
defining macros and blocks, and applying filters. It is a dependency of the
`MulleScionHTMLPreprocessor` companion project and is used for dynamic
HTML/text generation in mulle-sde projects.

Key features at a high level:

- Twig/Django-like `{{ variable }}` and `{% command %}` syntax.
- Arbitrary Objective-C method calls in templates via `NSInvocation` and
  Key-Value-Coding (`valueForKeyPath:`).
- A pluggable data source protocol (`MulleScionDataSource`) whose every method
  has a default implementation in `NSObject`; you only override what you want
  to restrict or intercept.
- `MulleScionLocals` provides a dictionary-like set of local variables, some of
  which can be read-only (protected from template mutation).
- Parser/Printer split: `MulleScionParser` builds an AST
  (`MulleScionTemplate` and the `MulleScionObjectModel` classes), and
  `MulleScionPrinter` walks that AST to produce output.
- Template output can go to any `id <MulleScionOutput>` object (e.g. an
  `NSMutableString`) or into a returned `NSString`.
- Optional caching of parsed templates via archived (optionally compressed)
  `.scionz` template archives.

Deliberate design limits (from README): no arithmetic or bitwise logic in
templates, `&&`/`||` have no precedence (use parentheses), and method calls use
`NSInvocation` (so varargs methods, C structs, and C arrays are problematic).

This is the `MulleScion` implementation only; it depends on the mulle-objc
Foundation and HTTP/InetOS foundation libraries.

## 2. Key Concepts & Design Philosophy

- **Data source centric.** Everything a template can read goes through the
  `MulleScionDataSource` protocol. All its methods have default `NSObject`
  implementations (built on KVC), so a plain `NSDictionary`/`NSArray`/object
  works out of the box. Overriding these methods is an access-control and
  customization point, not a requirement.
- **Two phase pipeline.** *Parse* a template source (file, URL, or UTF-8 C
  string) with `MulleScionParser` into a `MulleScionTemplate` AST. *Render* the
  AST with `MulleScionPrinter` into `id <MulleScionOutput>` (an object
  implementing `-appendString:`) or back into an `NSString`.
- **Convenience facade.** `MulleScionTemplate( Convenience)` hides the
  pipeline: `descriptionWithTemplateFile:dataSource:` is the "don't think, use
  this" one-liner. `MulleScion.m` uses this as its documented entry point.
- **AST immutability after parse.** After template expansion, a
  `MulleScionObject` is not mutated by MulleScion ("after template expansion a
  MulleScionObject won't be mutated by MulleScion").
- **Local variables vs data source.** `MulleScionLocals` holds rendering-time
  state and built-in values; the data source is the user-provided context.
  Default built-in locals include `NSNotFound`, string encodings,
  `NSOrderedSame`/`Ascending`/`Descending`, and a function table
  (`MulleScionFunctionTableKey`) holding `NSLog`, `NSStringFromRange`,
  `NSMakeRange`, `NSLocalizedString`, `defined`, `filter`.
- **`MulleScionNull`.** `nil` results are materialized as the `MulleScionNull`
  singleton (`extern id MulleScionNull`, class `_MulleScionNull`) so template
  evaluation can distinguish "nil" from "absent".
- **Read-only locals.** Keys set via `setObject:forReadOnlyKey:` cannot be
  overwritten or removed by templates; attempts raise
  `NSInvalidArgumentException`.

## 3. Core API & Data Structures

### 3.1. `MulleScion.h` (umbrella + convenience facade)

- `#define MULLE_SCION_VERSION   ((1862UL << 20) | (0 << 8) | 2)` — version as
  `(major << 20) | (minor << 8) | patch`.
- `@protocol MulleScionStringOrURL` — empty marker protocol; `NSString` and
  `NSURL` both conform. Used as the declared `location`/`fileName` parameter
  type so either a path string or an `NSURL` can be passed.
- `extern char   MulleScionFrameworkVersion[];` — runtime version string.

#### `MulleScionTemplate( Convenience)` (declared in `MulleScion.h`)

- **Purpose:** One-call convenience API; real implementation is in
  `MulleScion.m`.

- **Class methods:**
  ```objc
  + (NSString *) descriptionWithTemplateFile:(NSObject <MulleScionStringOrURL> *) location
                                  dataSource:(id <MulleScionDataSource>) dataSource;

  + (NSString *) descriptionWithTemplateFile:(NSObject <MulleScionStringOrURL> *) location
                                  dataSource:(id <MulleScionDataSource>) dataSource
                                  searchPath:(NSArray *) searchPath
                              localVariables:(id <MulleScionLocals>) locals;

  + (NSString *) descriptionWithTemplateFile:(NSObject <MulleScionStringOrURL> *) fileName
                            propertyListFile:(NSObject <MulleScionStringOrURL> *) plistFileName
                                  searchPath:(NSArray *) searchPath
                              localVariables:(id <MulleScionLocals>) locals;

  + (NSString *) descriptionWithTemplateFile:(NSObject <MulleScionStringOrURL> *) fileName
                            propertyListFile:(NSObject <MulleScionStringOrURL> *) plistFileName;

  + (NSString *) descriptionWithUTF8Template:(char *) s
                                  dataSource:(id <MulleScionDataSource>) dataSource
                                  searchPath:(NSArray *) searchPath
                              localVariables:(id <MulleScionLocals>) locals;

  + (NSString *) descriptionWithUTF8Template:(char *) s
                                  dataSource:(id <MulleScionDataSource>) dataSource;

  + (BOOL) writeToOutput:(id <MulleScionOutput>) output
            templateFile:(NSObject <MulleScionStringOrURL> *) fileName
              dataSource:(id <MulleScionDataSource>) dataSource
              searchPath:(NSArray *) searchPath
          localVariables:(id <MulleScionLocals>) locals;
  ```
  - Note there is **no** three-argument `descriptionWithUTF8Template:dataSource:searchPath:`
    variant; the `searchPath:` variant also takes `localVariables:`.

- **-Instance methods** (create a `MulleScionTemplate` directly):
  ```objc
  - (id) initWithUTF8String:(char *) s;
  - (id) initWithFile:(NSString *) fileName;            // template or archive
  - (id) initWithContentsOfFile:(NSObject <MulleScionStringOrURL> *) fileName;

  - (id) initWithUTF8String:(char *) s
                 searchPath:(NSArray *) searchPath;

  - (id) initWithFile:(NSString *) fileName            // template or archive
           searchPath:(NSArray *) searchPath;

  - (id) initWithContentsOfFile:(NSObject <MulleScionStringOrURL> *) fileName
                     searchPath:(NSArray *) searchPath;

  - (NSString *) descriptionWithDataSource:(id) dataSource
                            localVariables:(id <MulleScionLocals>) locals;

  - (void) writeToOutput:(id <MulleScionOutput>) output
              dataSource:(id <MulleScionDataSource>) dataSource
          localVariables:(id <MulleScionLocals>) locals;
  ```

#### `MulleScionTemplate( Caching)` (declared in `MulleScion.h`)

Toggled off on iOS (`DONT_HAVE_MULLE_SCION_CACHING`). Controlled at runtime
via environment variable `MulleScionCacheDirectory` or
`NSUserDefaults` key `MulleScionCacheDirectory`.

```objc
+ (void) setCacheDirectory:(NSString *) directory;
+ (NSString *) cacheDirectory;
+ (void) setCacheEnabled:(BOOL) flag;
+ (BOOL) isCacheEnabled;
- (NSString *) cachePathForPath:(NSString *) fileName;
```

### 3.2. `MulleScionDataSourceProtocol.h`

- **`@protocol MulleScionDataSource`:** data access and access-control hook.
  `NSObject` provides default implementations for every method, so implementing
  none of them is valid. `valueForKeyPath:` is the documented minimal
  requirement ("your object must implement KVC (well at least this method)").
  "You probably want to call super afterwards." Raise an exception to reject.

  ```objc
  @protocol MulleScionDataSource

  - (id) valueForKeyPath:(NSString *) keyPath;

  - (id) mulleScionValueForKeyPath:(NSString *) keyPath
                    localVariables:(id <MulleScionLocals>) locals;

  - (id) mulleScionValueForKeyPath:(NSString *) keyPath
                            target:(id) target
                    localVariables:(id <MulleScionLocals>) locals;

  - (id) mulleScionValueForKeyPath:(NSString *) keyPath
                  inLocalVariables:(id <MulleScionLocals>) locals;

  - (id) mulleScionMethodSignatureForSelector:(SEL) sel
                                       target:(id) target;

  - (Class) mulleScionClassFromString:(NSString *) s;

  - (id) mulleScionPipeString:(NSString *) s
                throughMethod:(NSString *) identifier
               localVariables:(id <MulleScionLocals>) locals;

  - (id) mulleScionFunction:(NSString *) identifier
            evaledArguments:(NSArray *) evaledArguments
                  arguments:(NSArray *) arguments
             localVariables:(id <MulleScionLocals>) locals;

  @end
  ```

- **`@interface NSObject( MulleScionDataSource)`:** default implementations;
  provides `- (id) mulleScionDataSource;` as well.

### 3.3. `MulleScionLocals.h`

- **`@protocol MulleScionLocals < NSObject, NSCopying>`:** local variable
  storage with read-only support and fast enumeration.

  ```objc
  - (void) setObject:(id) object
      forReadOnlyKey:(NSString *) key;
  - (void) setObject:(id) object
              forKey:(NSString *) key;
  - (id) objectForKey:(NSString *) key;
  - (void) removeAllObjects;
  - (void) removeObjectForKey:(NSString *) key;
  - (void) removeObjectForReadOnlyKey:(NSString *) key;
  - (id) valueForKeyPath:(NSString *) key;
  - (id) takeValue:(id) value
        forKeyPath:(NSString *) key;

  - (void) addEntriesFromLocals:(id <MulleScionLocals>) other;

  - (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *) state
                                     objects:(id *) buffer
                                       count:(NSUInteger) len;
  ```

- **`@interface NSMutableDictionary( MulleScionLocals) < MulleScionLocals>`:**
  adapts `NSMutableDictionary`; `setObject:forReadOnlyKey:` does not enforce
  read-only there, and `addEntriesFromLocals:` aborts (unsupported).

- **`@interface MulleScionLocals : _MulleObjCConcreteMutableDictionary
  < MulleScionLocals>`:** the concrete class; enforces
  read-only-per-key semantics (raising `NSInvalidArgumentException` on
  overwrites/removals of read-only keys) and tracks keys in an
  `NSMutableSet *_readOnlyKeys`.

### 3.4. `MulleScionOutputProtocol.h`

- **`@protocol MulleScionOutput`:** rendering sink.
  ```objc
  @protocol MulleScionOutput
  - (void) appendString:(NSString *) s;
  @end
  ```
- `@interface NSMutableString( MulleScionOutput) < MulleScionOutput>` —
  an `NSMutableString` can be passed directly as an output.

### 3.5. `MulleScionParser.h`

- **`@protocol MulleScionPreprocessor < MulleObjCThreadSafe>`:** optional
  pre-processing hook, called before parsing; inherited across includes.
  ```objc
  - (NSData *) preprocessedData:(NSData *) data;
  ```

- **`@interface MulleScionParser : NSObject`** — creates `MulleScionTemplate`
  ASTs from template sources. Use this instead of convenience methods when you
  want to parse once and cache the parsed `MulleScionTemplate`.

  ```objc
  + (MulleScionParser *) parserWithContentsOfFile:(NSString *) fileName
                                       searchPath:(NSArray *) searchPath;
  + (MulleScionParser *) parserWithUTF8String:(char *) s
                                   searchPath:(NSArray *) searchPath;
  + (MulleScionParser *) parserWithContentsOfURL:(NSURL *) url;

  - (id) initWithData:(NSData *) data
             fileName:(NSString *) fileName
           searchPath:(NSArray *) searchPath;

  - (MulleScionTemplate *) template;
  - (NSDictionary *) dependencyTable;

  - (void) parser:(void *) parser
            error:(NSString *) reason
         fileName:(NSString *) fileName
             line:(NSString *) line
       lineNumber:(NSUInteger) lineNumber
      columnNumber:(NSUInteger) lineNumber;

  - (void)   parser:(void *) parser
            warning:(NSString *) reason
           fileName:(NSString *) fileName
               line:(NSString *) line
         lineNumber:(NSUInteger) lineNumber
       columnNumber:(NSUInteger) lineNumber;

  - (NSString *) fileName;

  - (void) setPreprocessor:(NSObject <MulleScionPreprocessor> *) preprocessor;
  - (NSObject <MulleScionPreprocessor> *) preprocessor;
  - (NSData *) preprocessedData:(NSData *) data;

  - (void) setSearchPath:(NSArray *) array;
  - (NSArray *) searchPath;

  - (BOOL) debugFilePaths;
  ```

### 3.6. `MulleScionPrinter.h`

- **`@interface MulleScionPrinter : NSObject`** — renders a parsed
  `MulleScionTemplate` against a data source.

  ```objc
  - (id) initWithDataSource:(id) dataSource;

  - (NSString *) describeWithTemplate:(MulleScionTemplate *) template;
  - (void) writeToOutput:(id <MulleScionOutput>) output
                template:(MulleScionTemplate *) template;

  - (id <MulleScionLocals>) defaultLocalVariables;
  - (void) setDefaultLocalVariables:(id <MulleScionLocals>) dictionary;
  ```

### 3.7. `MulleScionObjectModel.h` (template AST)

The parsed template is a linked list (`next_` pointer) of
`MulleScionObject`-derived nodes starting with the `MulleScionTemplate` root.
Core classes and factory methods (all `+new*` factories return +1 objects,
use `NS_CONSUMED`/retained ownership semantics — never autorelease
`NS_CONSUMED` arguments):

- **`MulleScionObject`** (base): `next_` (`MulleScionObject *`, public via
  `MULLE_SCION_OBJECT_NEXT_POINTER_VISIBILITY`) and protected
  `lineNumber_`. Factories:
  - `+ (id) newWithLineNumber:(NSUInteger) nr;`
  - `- (id) initWithLineNumber:(NSUInteger) nr;`
  - Type predicates: `isLexpr`, `isTemplate`, `isIdentifier`, `isTerminator`,
    `isFunction`, `isVariable`, `isMethod`, `isParameterAssignment`, `isConcat`, `isIf`,
    `isElse`, `isEndIf`, `isFor`, `isEndFor`, `isWhile`, `isEndWhile`, `isBlock`,
    `isParentBlock`, `isEndBlock`, `isBlockType`, `isPipe`, `isDot`, `isIndexing`,
    `isJustALinefeed`, `isDictionaryKey`, `isMacro`.
  - `- (Class) terminatorClass;` and `- (NSUInteger) lineNumber;`
- **`MulleScionValueObject : MulleScionObject`**: carries `value_`; getter
  `- (id) value;` and `- (BOOL) needsParenthesis;` (default NO).
- **`MulleScionTemplate : MulleScionValueObject`** (root):
  `- (id) initWithFilename:(NSString *) s;`, `- (NSString *) fileName;`.
- **`MulleScionPlainText : MulleScionValueObject`**:
  `+ (id) newWithRetainedString:(NSString *) NS_CONSUMED s lineNumber:(NSUInteger) nr;`
  plus re-declared `- (BOOL) isJustALinefeed;`.
- **`MulleScionExpression : MulleScionValueObject`**: base for expressions;
  `- (NSInteger) precedence;` (default `NSIntegerMax`).
- **`MulleScionNumber : MulleScionExpression`**: `+ (id) newWithNumber:(NSNumber *) s lineNumber:(NSUInteger) nr;`
- **`MulleScionString : MulleScionExpression`**: `+ (id) newWithString:(NSString *) s lineNumber:(NSUInteger) nr;`
- **`MulleScionSelector : MulleScionString`** — opaque subclass.
- **`MulleScionArray : MulleScionExpression`**: `+ (id) newWithArray:(NSArray *) s lineNumber:(NSUInteger) nr;`
- **`MulleScionDictionary : MulleScionExpression`**: `+ (id) newWithDictionary:(NSDictionary *) s lineNumber:(NSUInteger) nr;`
- **`MulleScionIdentifierExpression : MulleScionExpression`**:
  `+ (id) newWithIdentifier:(NSString *) s lineNumber:(NSUInteger) nr;`, `- (NSString *) identifier;`
- **`MulleScionVariable : MulleScionIdentifierExpression`** — a variable reference.
- **`MulleScionOperatorExpression : MulleScionExpression`**: `- (NSString *) operator;`
- **`MulleScionUnaryOperatorExpression : MulleScionOperatorExpression`**:
  `+ (id) newWithRetainedExpression:(MulleScionExpression *) NS_CONSUMED left lineNumber:(NSUInteger) nr;`
- **`MulleScionNot : MulleScionUnaryOperatorExpression`**, **`MulleScionParenthesis : MulleScionUnaryOperatorExpression`**.
- **`MulleScionBinaryOperatorExpression : MulleScionOperatorExpression`**:
  `+ (id) newWithRetainedLeftExpression:(MulleScionExpression *) NS_CONSUMED left retainedRightExpression:(MulleScionExpression *) NS_CONSUMED right lineNumber:(NSUInteger) nr;`
  and `- (MulleScionBinaryOperatorExpression *) hierarchicalExchange:(MulleScionBinaryOperatorExpression *) other;`
- **`MulleScionAnd`, `MulleScionOr`, `MulleScionPipe`, `MulleScionIndexing`,
  `MulleScionDot`, `MulleScionConcat : MulleScionBinaryOperatorExpression`**.
- **`typedef enum { MulleScionEqual, MulleScionNotEqual, MulleScionLessThan, MulleScionGreaterThan, MulleScionLessThanOrEqualTo, MulleScionGreaterThanOrEqualTo, MulleScionNoComparison = -1 } MulleScionComparisonOperator;`**
- **`MulleScionComparison : MulleScionBinaryOperatorExpression`**:
  `+ (id) newWithRetainedLeftExpression:retainedRightExpression:comparison:lineNumber:`
  (adds `MulleScionComparisonOperator comparison_`).
- **`MulleScionFunction : MulleScionIdentifierExpression`** (arguments):
  `+ (id) newWithIdentifier:(NSString *) s arguments:(NSArray *) arguments lineNumber:(NSUInteger) nr;`, `- (NSArray *) arguments;`
- **`MulleScionParent : MulleScionIdentifierExpression`**:
  `+ (id) newWithIdentifier:lineNumber:`.
- **`MulleScionParameterAssignment : MulleScionIdentifierExpression`**:
  `+ (id) newWithIdentifier:(NSString *) identifier retainedExpression:(MulleScionExpression *) NS_CONSUMED expr lineNumber:(NSUInteger) nr;`, `- (MulleScionExpression *) expression;`
- **`MulleScionAssignmentExpression : MulleScionExpression`**:
  `+ (id) newWithRetainedLeftExpression:retainedRightExpression:lineNumber:`
- **`MulleScionMethod : MulleScionExpression`** (SEL + arguments):
  `+ (id) newWithRetainedTarget:(MulleScionExpression *) NS_CONSUMED target methodName:(NSString *) methodName arguments:(NSArray *) arguments lineNumber:(NSUInteger) nr;`, `- (BOOL) isSelfMethod;`
- **`MulleScionConditional : MulleScionExpression`** (ternary):
  `+ (id) newWithRetainedLeftExpression:retainedMiddleExpression:retainedRightExpression:lineNumber:`
- **`MulleScionCommand : MulleScionObject`** (commands print nothing):
  `- (NSString *) commandName;`,
  `- (MulleScionObject *) terminateToEnd:(MulleScionObject *) curr;`,
  `- (MulleScionObject *) terminateToElse:(MulleScionObject *) curr;`
- **`MulleScionTerminator : MulleScionCommand`**, **`MulleScionEndFor`, `MulleScionElse`, `MulleScionEndIf`, `MulleScionEndWhile`, `MulleScionEndBlock`, `MulleScionEndFilter : MulleScionTerminator`**.
- **`MulleScionElseFor : MulleScionElse`**.
- **`MulleScionExpressionCommand : MulleScionCommand`**:
  `+ (id) newWithRetainedExpression:(MulleScionExpression *) NS_CONSUMED expr lineNumber:(NSUInteger) nr;`
- **`MulleScionLog : MulleScionExpressionCommand`**.
- **`MulleScionSet : MulleScionCommand`** (assignment):
  `+ (id) newWithRetainedLeftExpression:retainedRightExpression:lineNumber:`.
- **`MulleScionFor : MulleScionSet`** ("for is pretty much the same as an
  assignment, just looped").
- **`MulleScionIf : MulleScionExpressionCommand`**, **`MulleScionWhile : MulleScionIf`**.
- **`MulleScionBlock : MulleScionCommand`** (template inheritance):
  `+ (id) newWithIdentifier:(NSString *) identifier fileName:(NSString *) fileName lineNumber:(NSUInteger) nr;`,
  `- (NSString *) identifier;`, `- (NSString *) fileName;`
- **`MulleScionParentBlock : MulleScionObject`**.
- **`MulleScionMethodCall`, `MulleScionFunctionCall : MulleScionExpressionCommand`**.
- **`MulleScionFilter : MulleScionExpressionCommand`** with flag enum:
  `FilterPlaintext = 0x1, FilterOutput = 0x2, FilterApplyStackedFilters = 0x4`;
  factory `+ (id) newWithRetainedExpression:(MulleScionExpression *) NS_CONSUMED expr flags:(NSUInteger) flags lineNumber:(NSUInteger) nr;`
- **`MulleScionMacro : MulleScionTemplate`**:
  `+ (id) newWithIdentifier:(NSString *) s function:(MulleScionFunction *) function body:(MulleScionTemplate *) body fileName:(NSString *) fileName lineNumber:(NSUInteger) nr;`
  with getters `identifier`, `function`, `body`.
- **`MulleScionRequires : MulleScionCommand`**:
  `+ (id) newWithIdentifier:(NSString *) identifier lineNumber:(NSUInteger) nr;`, `- (NSString *) identifier;`

### 3.8. `MulleScionObjectModel+Printing.h` (rendering internals)

- `- (MulleScionObject *) renderInto:(id <MulleScionOutput>) output
   localVariables:(id <MulleScionLocals>) locals
       dataSource:(id <MulleScionDataSource>) dataSource;` — the recursive
  render primitive; implemented per AST node in `MulleScionObjectModel+Printing.m`.
- `- (id <MulleScionLocals>) localVariablesWithDefaultValues:(id <MulleScionLocals>) defaults;`
  and `+ (id <MulleScionLocals>) mulleScionDefaultBuiltinFunctionTable;` on
  `MulleScionTemplate( Printing)`.
- C functions:
  ```objc
  NSString  *MulleScionFilteredString( NSString *value,
                                       id <MulleScionLocals> locals,
                                       id <MulleScionDataSource> dataSource,
                                       NSUInteger bit);

  void   MulleScionRenderString( NSString *value,
                                 id <MulleScionOutput> output,
                                 id <MulleScionLocals> locals,
                                 id <MulleScionDataSource> dataSource);

  void   MulleScionRenderPlaintextString( NSString *value,
                                          id <MulleScionOutput> output,
                                          id <MulleScionLocals> locals,
                                          id <MulleScionDataSource> dataSource);
  ```
- Local-variable keys (extern `NSString *` constants): `MulleScionArgumentsKey`,
  `MulleScionRenderOutputKey`, `MulleScionCurrentFileKey`, `MulleScionCurrentLineKey`,
  `MulleScionCurrentFunctionKey`, `MulleScionFoundationKey`, `MulleScionFunctionTableKey`,
  `MulleScionVersionKey`, `MulleScionShouldFilterPlainTextKey`, `MulleScionForOpenerKey`,
  `MulleScionForSeparatorKey`, `MulleScionForCloserKey`, `MulleScionEvenKey`, `MulleScionOddKey`.

### 3.9. `MulleScionTemplate+CompressedArchive.h`

Archived templates (`.scionz`) for caching; faster to load than parsing when
there is no preprocessor dependency.

```objc
- (id) initWithContentsOfArchive:(NSString *) fileName;
- (BOOL) writeArchive:(NSString *) fileName;
- (BOOL) writeArchive:(NSString *) fileName
                keyed:(BOOL) keyed;

+ (BOOL) isArchivedTemplatePath:(NSString *) path
                   isCompressed:(BOOL *) isCompressed;

+ (BOOL) isArchivedTemplatePath:(NSString *) path;  // checks extension first
```

### 3.10. `MulleScionPrintingException.h`

Helpers used inside built-in functions and pipes:

```objc
void  MULLE_NO_RETURN   MulleScionPrintingException( NSString *exceptionName, id <MulleScionLocals> locals, NSString *format, ...);

void  MulleScionPrintingValidateArgumentCount( NSArray *arguments, NSUInteger n, id <MulleScionLocals> locals);
id    MulleScionPrintingValidatedArgument( NSArray *arguments, NSUInteger i,  Class cls, id <MulleScionLocals> locals);
```

### 3.11. `MulleScionNull.h`

```objc
@interface _MulleScionNull : NSObject
@end
extern id   MulleScionNull;
```

The singleton is used to represent explicitly-nil evaluation results in a
template.

### 3.12. Utility categories and helper classes

- **`NSObject+MulleScionDescription.h`** — `- (NSString *) mulleScionDescriptionWithLocalVariables:(id <MulleScionLocals>) context;`
  plus formatting keys: `MulleScionDateFormatterKey`, `MulleScionNumberFormatterKey`,
  `MulleScionDateFormatKey`, `MulleScionNumberFormatKey`, `MulleScionLocaleKey`,
  `MulleScionNilDescriptionKey`, `MulleScionStringLengthKey`, `MulleScionStringEllipsisKey`.
- **`NSString+MulleScion.h`** — `- (NSString *) htmlEscapedString;`,
  `- (NSString *) urlEscapedString;`, `- (BOOL) matches:(NSString *) regex;`.
- **`NSObject+KVC_Compatibility.h`** — `- (void) takeValue:(id) value forKeyPath:(NSString *) keyPath;`
  (KVC setter).
- **`NSFileHandle+MulleOutputFileHandle.h`** — `+ (NSFileHandle *) mulleOutputFileHandleWithFilename:(NSString *) outputName;`,
  `+ (NSFileHandle *) mulleErrorFileHandleWithFilename:(NSString *) outputName;`.
- **`exists.h`** — a syntax-extension class performing file tests:
  `+ (NSNumber *) any:(id) arg;`, `+ (NSNumber *) file:(id) arg;`,
  `+ (NSNumber *) directory:(id) arg;` (a commented-out `url:` variant exists).
- **`MulleMutableLineNumber.h`** — `@interface MulleMutableLineNumber : NSNumber`
  with `- (void) setUnsignedInteger:(NSUInteger) value;` (avoids object churn for
  the current-line local variable).
- **`MulleCommonObjCRuntime.h`** — `static inline Class   MulleGetClass( id self)`
  returning the class of an object; portable across mulle-objc and Apple runtimes.
- **`MulleObjCCompilerSettings.h`** — attribute macros `NS_RETURNS_RETAINED`,
  `NS_RETURNS_NOT_RETAINED`, `NS_RELEASES_ARGUMENT`, `NS_CONSUMED`,
  `NS_CONSUMES_SELF`, `MULLE_NO_RETURN`.

### 3.13. `MulleScionObjectModel+NSCoding.h`, `+Parsing.h`, `+BlockExpansion.h`, `+MacroExpansion.h`, `+TraceDescription.h` (advanced)

- **NSCoding/NSCopying** (`MulleScionObjectModel+NSCoding.h`):
  `- initWithCoder:`, `- encodeWithCoder:`, `- copyWithZone:` for the whole AST
  (used by the archive cache).
- **Parsing helpers** (`MulleScionObjectModel+Parsing.h`):
  `- (void) appendRetainedObject:(MulleScionObject *) NS_CONSUMED obj;`
  and parser bookkeeping: `- (MulleScionObject *) behead;`,
  `- (MulleScionObject *) tail;`, `- (NSUInteger) count;`,
  `- (BOOL) snarfsScion;`. This header forces
  `MULLE_SCION_OBJECT_NEXT_POINTER_VISIBILITY` to `@public` while parsing.
- **Block expansion** (`MulleScionObjectModel+BlockExpansion.h`):
  `- (MulleScionObject *) ownerOfBlockWithIdentifier:(NSString *) identifier;`,
  `- (MulleScionObject *) nextOwnerOfBlockCommand;`,
  `- (MulleScionBlock *) replaceOwnedBlockWithRetainedBlock:(MulleScionBlock *) NS_CONSUMED replacement;`,
  deprecated `replaceOwnedBlockWithBlock:`, and
  `- (void) expandBlocksUsingTable:(NSDictionary *) table;` on `MulleScionTemplate`.
- **Macro expansion** (`MulleScionObjectModel+MacroExpansion.h`):
  `- (NSDictionary *) parametersWithArguments:(NSArray *) arguments fileName:(NSString *) fileName lineNumber:(NSUInteger) line;`,
  `- (MulleScionTemplate *) expandedBodyWithParameters:(NSDictionary *) parameters fileName:(NSString *) fileName lineNumber:(NSUInteger) line;`
  and variable substitution: `- (id) newExpandedVariableWithIdentifier:withExpression:` (returns retained),
  deprecated `replaceVariableWithIdentifier:withExpression:`.
- **Trace description** (`MulleScionObjectModel+TraceDescription.h`):
  `- (NSString *) traceValueDescription;` on `NSObject`;
  `traceDescription`, `dumpDescription`, `templateDescription` on
  `MulleScionObject`; C helpers `mulleShortenedString( NSString *s, size_t max)`,
  `mulleLinefeedEscapedString( NSString *s)`,
  `mulleLinefeedEscapedShortenedString( NSString *s, size_t max)`.

## 4. Performance Characteristics

- **Parse time:** single pass over the template text building the AST. Parsing
  an archive (`initWithContentsOfArchive:`) or loading a cached `.scionz` is
  faster than re-parsing.
- **Render time:** linear over the AST; each node calls into KVC/message
  dispatch. `NSMutableString` output accumulates via `-appendString:`.
- **`MulleScionLocals`** is an `NSMutableDictionary` subclass, so
  `objectForKey:`/`setObject:forKey:` are O(1) average like `NSMutableDictionary`.
- **Caching:** with caching enabled, parsed templates are archived to disk;
  note the documented bug: templates with the same filename in different
  subdirectories collide (cache filename is derived from
  `lastPathComponent`), and the archive is only usable when the template has no
  preprocessor dependency (`MulleScion.m` comment: keyed encoding is slower
  than just parsing the template anew).
- **Thread-safety:** not thread-safe for shared mutable state. `MulleScionParser`,
  `MulleScionTemplate`, and `MulleScionPrinter` are plain `NSObject` instances —
  do not render one template concurrently; create separate instances per
  thread/use if needed. The optional `MulleScionPreprocessor` protocol
  *requires* `MulleObjCThreadSafe` conformance.
- **Memory:** non-ARC project; objects returned by `+new*` factories carry
  +1 retain counts, `NS_CONSUMED` arguments are taken over by the callee, and
  `MulleScionObject` nodes form a retained linked list that is released
  together with the template root.

## 5. AI Usage Recommendations & Patterns

- **Use the convenience one-liner for simple renders:**
  `[MulleScionTemplate descriptionWithTemplateFile:@"file.scion" dataSource:dataSource]`.
  Returned `NSString` is autoreleased.
- **Prefer `+parser*/+new*` factory methods** over `alloc`/`init` in new code
  (`+ (MulleScionParser *) parserWithUTF8String:searchPath:` etc.). Per the
  mulle-objc project style: never call `-alloc/-init/init`/`+new` without
  `-autorelease` (except in `-init`), never call `-release` except in
  `-dealloc`, and avoid dot-syntax for property access — use message sends.
- **`NS_CONSUMED` arguments (including `NS_CONSUMED` expressions) are
  owned by the callee** — pass retained objects and do not also
  `autorelease` them. Non-consumed arguments are borrowed; autorelease these
  yourself when needed. Never instantiate abstract classes
  (`MulleScionExpression`, `MulleScionCommand`, etc.) directly — use concrete
  subclasses (`MulleScionNumber`, `MulleScionString`, `MulleScionVariable`, ...)
  for tests and AST construction.
- **Do not access `_`-prefixed ivars** (`next_`, `value_`, `lineNumber_`,
  `_readOnlyKeys`, `dataSource_`, ...). Use the declared accessors
  (`value`, `lineNumber`, `next_` traversable only through `renderInto:`, etc.).
- **Build the data source as an access-control layer.** Override
  `mulleScionValueForKeyPath:localVariables:` (and call `super`) to whitelist
  keys and block method calls; raise an `NSException` to veto. This is the
  documented pattern to protect against arbitrary template code execution
  ("execution of arbitrary methods can be a huge security hole if the template
  is writable for users") — a customer-written template can call *any* method.
- **`MulleScionLocals` read-only keys** protect state from template mutation
  (`setObject:forReadOnlyKey:`); ordinary `setObject:forKey:` values may be
  overwritten by templates.
- **Template limitations to respect:** no arithmetic/bitwise operators; no
  operator precedence for `&&`/`||` (wrap in parentheses); varargs methods,
  C structs, and C arrays are unreliable under `NSInvocation`; missing keys
  simply yield `nil` output.
- **Use `writeToOutput:` targeting `NSMutableString`** when building large
  output incrementally instead of concatenating full `NSString` results.
- **Parse-once-render-many:** call `MulleScionParser`/`-template` once and
  reuse the `MulleScionTemplate` for repeated renders with the `Printer`, or
  enable the archive cache for template files.

## 6. Integration Examples

Note: follow the mulle-objc project style below — 3-space indent, Allman
braces, one variable per line, aligned declarations, `return( expr);`,
message-send syntax only, no `alloc/init`/`release` outside `-init`/`-dealloc`,
prefer factory methods.

### Example 1: "Don't think" convenience render from a template file

```objc
#import <MulleScion/MulleScion.h>
#include <stdio.h>


@interface MyDataSource : NSObject
@end

@implementation MyDataSource

- (id) mulleScionValueForKeyPath:(NSString *) keyPath
                  localVariables:(id <MulleScionLocals>) locals
{
   // whitelist single keys, then hand everything else to the default
   if( [keyPath isEqualToString:@"name"])
      return( @"World");

   return( [super mulleScionValueForKeyPath:keyPath
                             localVariables:locals]);
}

@end


int   main( void)
{
   MyDataSource   *dataSource;
   NSString       *output;

   dataSource = [[MyDataSource new] autorelease];

   // template file: test.scion   ->  "Hello {{ name }}!"
   output = [MulleScionTemplate descriptionWithTemplateFile:@"test.scion"
                                                 dataSource:dataSource];
   printf( "%s\n", [output UTF8String]);   // prints: Hello World!

   return( 0);
}
```

### Example 2: Render an inline UTF-8 template with locals and output

```objc
#import <MulleScion/MulleScion.h>
#include <stdio.h>


int   main( void)
{
   MulleScionLocals   *locals;
   NSDictionary       *dataSource;
   NSString           *output;

   locals = [MulleScionLocals object];

   // read-only locals cannot be clobbered by template code
   [locals setObject:@"Mulle"
      forReadOnlyKey:@"company"];

   // any KVC-capable object works; NSObject provides default dataSource impls
   dataSource = [NSDictionary dictionary];

   output = [MulleScionTemplate descriptionWithUTF8Template:
                                     "{{ company }} rules!"
                                                dataSource:dataSource
                                                searchPath:nil
                                            localVariables:locals];
   printf( "%s\n", [output UTF8String]);   // prints: Mulle rules!

   return( 0);
}
```

### Example 3: Parse once, render several times

```objc
#import <MulleScion/MulleScion.h>
#include <stdio.h>


static NSString   *renderGreeting( MulleScionTemplate *template, NSString *name)
{
   MulleScionLocals   *locals;
   MulleScionPrinter  *printer;
   NSMutableString    *output;

   locals  = [MulleScionLocals object];
   [locals setObject:name
              forKey:@"name"];

   printer = [[MulleScionPrinter new] autorelease];
   [printer setDefaultLocalVariables:locals];

   output = [NSMutableString string];
   [printer writeToOutput:output
                 template:template];
   return( output);
}


int   main( void)
{
   MulleScionParser   *parser;
   MulleScionTemplate *template;

   parser   = [MulleScionParser parserWithUTF8String:
                "hi {{ name }} ({{ company }})"
                                         searchPath:nil];
   template = [parser template];          // parse once

   printf( "%s\n", [renderGreeting( template, @"A") UTF8String]);
   printf( "%s\n", [renderGreeting( template, @"B") UTF8String]);

   return( 0);
}
```

Note: `{{ company }}` is a built-in local (`MulleScionFoundationKey`, e.g.
`"Mulle"` on mulle-objc) provided by the printer, demonstrating built-in
locals.

### Example 4: Control flow — `for`/`if` over a collection data source

```twig
{# template.scion #}
{% for item in items %}
   {% if item#.isFirst %}
   <ul>
   {% endif %}
      <li>{{ item }}</li>
   {% if item#.isLast %}
   </ul>
   {% endif %}
{% else %}
   No items.
{% endfor %}
```

```objc
#import <MulleScion/MulleScion.h>
#include <stdio.h>


int   main( void)
{
   NSDictionary   *dataSource;
   NSString       *output;

   dataSource = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSArray arrayWithObjects:
                       @"a", @"b", @"c", nil], @"items", nil];

   output = [MulleScionTemplate descriptionWithTemplateFile:@"template.scion"
                                                 dataSource:dataSource];
   printf( "%s\n", [output UTF8String]);

   return( 0);
}
```

## 7. Dependencies

Direct mulle-sde library dependencies (from `.mulle/etc/sourcetree/config` and
`README.md`):

- `MulleFoundation` — the umbrella mulle-objc Foundation library (NSString,
  NSArray, NSDictionary, NSURL, KVC, etc.).
- `MulleObjCHTTPFoundation` — HTTP and HTML utility methods/classes.
- `MulleObjCInetOSFoundation` — OS-specific extensions to `NSHost`/`NSURL`.
- `mulle-objc-list` — introspection helper (`no-header`, `no-import`,
  `no-link` dependency).
- Build tooling: `mulle-test` (tests via `mulle-sde test craft`/`test run`);
  C API from mulle-c11-style conventions (compilers supported by `mulle-c11`).

## 8. Shortcut

An `asset/dox/api/toc/index.md` already existed. It was committed in commit
`485c7cd` ("refactor: standardize BSD license headers across the codebase",
2026-09-04). There have been no changes to `src/` (public headers) since that
commit, so the API documented here is current for the working tree at HEAD.
The previous file contained a number of inaccuracies (a non-existent
`mulleDescriptionForScionKeyPath:` data source method, a
`descriptionWithUTF8Template:dataSource:searchPath:` variant that is not
declared in any header, and ObjC examples not matching the project style), so
it has been rewritten verbatim from the current headers (`src/*.h`) and the
test sources (`test/`).