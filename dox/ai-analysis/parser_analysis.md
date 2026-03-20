# MulleScion C Parser - Comprehensive Analysis

## Overview
MulleScion is a **Twig-like template engine** written in **Objective-C** with a **C-based parser** core. The project is located at `/home/src/srcO/MulleWeb/MulleScion/`.

### Project Type
- **Language**: Objective-C (with embedded C parser)
- **Kind**: Library (template engine)
- **Scale**: 63 source files (mix of .m and .h)
- **Parser Implementation**: ~3,710 lines in `MulleScionParser+Parsing.m`

---

## Architecture Overview

### High-Level Components

```
┌─────────────────────────────────────────────────────────────┐
│                    MulleScionParser                          │
│              (NSObject-based Objective-C class)              │
├─────────────────────────────────────────────────────────────┤
│ Main Entry Points:                                           │
│ • -template          - Parse and return template             │
│ • -dependencyTable   - Get file dependencies                 │
│ • parseData:intoRoot - Core parsing method                   │
└─────────────────────────────────────────────────────────────┘
          ↓ delegates to ↓
┌─────────────────────────────────────────────────────────────┐
│              C Parser (embedded in .m)                       │
│        ~3,700 lines of pure C static functions              │
├─────────────────────────────────────────────────────────────┤
│ Core Functions:                                              │
│ • parser_init                                                │
│ • _parser_next_object        - Main parsing loop             │
│ • parser_do_command          - Parse {% ... %}              │
│ • parser_do_expression       - Parse {{ ... }}              │
│ • parser_grab_text_until_*   - Tokenization                  │
│ • parser_do_*                - Individual parsers            │
└─────────────────────────────────────────────────────────────┘
          ↓ produces ↓
┌─────────────────────────────────────────────────────────────┐
│           MulleScionObject Class Hierarchy                   │
│         (Represents parsed template structure)               │
├─────────────────────────────────────────────────────────────┤
│ MulleScionObject (base)                                      │
│ ├─ MulleScionTemplate (root node)                            │
│ ├─ MulleScionPlainText                                       │
│ ├─ MulleScionExpression (abstract)                           │
│ │  ├─ MulleScionVariable                                     │
│ │  ├─ MulleScionNumber                                       │
│ │  ├─ MulleScionString                                       │
│ │  ├─ MulleScionMethod                                       │
│ │  ├─ MulleScionFunction                                     │
│ │  └─ ... (many more expression types)                       │
│ └─ MulleScionCommand (abstract)                              │
│    ├─ MulleScionIf / MulleScionElse / MulleScionEndIf        │
│    ├─ MulleScionFor / MulleScionEndFor                       │
│    ├─ MulleScionBlock / MulleScionEndBlock                   │
│    └─ ... (many more command types)                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Template Syntax (Twig-inspired)

The parser understands the following syntax:

| Syntax | Purpose | Example |
|--------|---------|---------|
| `{{ expr }}` | Expression output | `{{ variable }}`, `{{ 42 }}` |
| `{% command %}` | Command execution | `{% if condition %}...{% endif %}` |
| `{# comment #}` | Comments | `{# This is ignored #}` |
| Plain text | Literal output | `Hello World` |

### Command Types
- **Control Flow**: `if`, `else`, `endif`, `for`, `endfor`, `while`, `endwhile`
- **Blocks**: `block`, `endblock`, `parent()`
- **Macros**: `macro`, `endmacro`
- **Includes**: `includes "file.html"`, `extends "base.html"`, `requires`
- **Variables**: `set`, `define`
- **Output**: `filter`, `apply`, `endfilter` (output modifiers)
- **Debugging**: `log`
- **Special**: `verbatim`, `endverbatim` (literal text)

### Expression Types Supported
- **Literals**: Numbers, strings, booleans (YES/NO), nil
- **Collections**: Arrays `@(...)`, dictionaries `@{...}`
- **Operators**: Logical (`&&`, `||`, `and`, `or`, unary `!`), comparison (`==`, `!=`, `<`, `>`, `<=`, `>=` plus `eq`/`ne`/`lt`/`le`/`gt`/`ge`), conditional (`?:`), concatenation (`~`), pipe (`|`), dot (`.`), indexing (`[...]`).
  - **Note**: binary arithmetic operators (`+`, `-`, `*`, `/`, `%`) are not parsed by the current expression parser.
- **Access**: Key paths, method calls `[target selector:arg]`, function calls
- **Special Keywords**: `selector(name)`, `not`, `parent()`

---

## Core Parser Structure (C-based)

### Main Parser State Machine

```c
typedef struct _parser {
    unsigned char      *buf;           // Input buffer
    unsigned char      *sentinel;      // End of buffer
    unsigned char      *curr;          // Current position
    NSUInteger         lineNumber;     // Current line number
    
    parser_memo        memo;           // Position checkpoint
    parser_memo        memo_scion;     // Scion tag checkpoint
    parser_memo        memo_interesting; // Error reporting checkpoint
    
    MulleScionObject   *first;         // Parsed object chain head
    
    // Callbacks for error/warning reporting
    parser_error_callback_t    *parser_do_error;
    parser_warning_callback_t  *parser_do_warning;
    
    id                 self;           // Objective-C object context
    SEL                sel;            // Selector for callbacks
    
    int                skipComments;   // Feature flag
    int                inMacro;        // Parsing macro body?
    int                wasMacroCall;   // Was last expression a macro?
    unsigned int       environment;    // Debug/feature flags
    
    NSString           *fileName;      // Source file name
    MulleScionParserTables tables;     // Block, definition, macro, dependency tables
    NSMutableArray     *converterStack; // For include converters
} parser;
```

### Environment Feature Flags
```c
enum {
    MULLESCION_ALLOW_GETENV_INCLUDES     = 0x01,  // Allow envvar-name includes (unquoted identifier resolved via getenv)
    MULLESCION_NO_HASHBANG               = 0x02,  // Skip #!/... first line
    MULLESCION_VERBATIM_INCLUDE_HASHBANG = 0x04,  // Preserve hashbang in includes
    MULLESCION_DUMP_COMMANDS             = 0x08,  // Debug: print parsed commands
    MULLESCION_DUMP_EXPRESSIONS          = 0x10,  // Debug: print expressions
    MULLESCION_DUMP_MACROS               = 0x40   // Debug: print macros
};
```

---

## Parsing Phases and Functions

### Phase 1: Initialization
```
parseData:intoRootObject:tables:ignoreErrors:
  ↓
parser_init(buf, len)
  - Zero out parser state
  - Set buffer and sentinel
  - Initialize line number to 1
  - Load environment flags from environment variables
  - Skip initial hashbang if present
```

### Phase 2: Main Parsing Loop
```
_parser_next_object(p, owner, last_type)
  ├─ Grab plain text until next template tag {{ or {% or {#
  │  └─ parser_grab_text_until_scion_start()
  │
  ├─ Switch on tag type:
  │  ├─ comment: skip and retry
  │  ├─ expression ({{ ... }}):
  │  │  └─ parser_do_expression_or_macro()
  │  └─ command ({% ... %}):
  │     └─ parser_do_commands()
  │
  └─ Create MulleScionObject and link into tree
```

### Phase 3: Expression Parsing

**Expression parsing (as implemented)**

There is **no classic precedence-climbing chain** (no `parser_do_additive_expr`, `parser_do_multiplicative_expr`, etc.). Instead:

- `parser_do_expression()` parses a **unary** expression via `parser_do_unary_expression()` and then calls `_parser_do_expression(p, left)`.
- `_parser_do_expression()` looks at the next token and, if it recognizes an operator, parses the **right-hand side by recursively calling `parser_do_expression()`**.
  - This makes the operator parsing largely **right-recursive/right-associative**, not a full precedence parser.
- The parser uses `-[MulleScionExpression precedence]` and `-[MulleScionExpression needsParenthesis]` to *complain* when parentheses are required (see `check_parentheses_left_right()`), rather than enforcing precedence by grammar structure.

**Operators handled by `_parser_do_expression()` include**:
- Logical: `&&`, `||`, `and`, `or`
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=` and textual `eq`/`ne`/`lt`/`le`/`gt`/`ge`
- Conditional: `?:`
- Concat: `~`
- Pipe/filter: `|`
- Dot: `.`
- Indexing: `expr[ indexExpr ]`

**Notably absent**: binary arithmetic operators (`+`, `-`, `*`, `/`, `%`) are not handled here (the code even notes: “path to arithmetic expression … but DO NOT WANT right now”).


**Primitive Expression Parsers:**
```c
parser_do_number()      // 42, 3.14, -5
parser_do_string()      // "hello"
parser_do_identifier()  // variable names
parser_do_keypath()     // foo.bar.baz
parser_do_array()       // @(1, 2, 3)
parser_do_dictionary()  // @{key: value}
parser_do_method()      // [target method:arg]
parser_do_function()    // functionName(arg1, arg2)
parser_do_selector()    // selector(name)
```

### Phase 4: Command Parsing

```
parser_do_command()
  ├─ Grab identifier: "if", "for", "block", etc.
  ├─ parser_opcode_for_string() → convert to opcode
  └─ Dispatch based on opcode:
     ├─ if/endif         → parser_do_if()
     ├─ for/endfor       → parser_do_for()
     ├─ block/endblock   → parser_do_block()
     ├─ macro/endmacro   → parser_do_macro()
     ├─ includes         → parser_do_includes()
     ├─ extends         → parser_do_extends()
     ├─ set              → parser_do_set()
     ├─ define           → parser_do_define()
     ├─ filter/apply     → parser_do_filter()
     ├─ verbatim         → parser_do_verbatim()
     ├─ log              → parser_do_log()
     └─ ... (more)
```

### Phase 5: Character-Level Tokenization

```c
// Core character functions
parser_peek_character()      // Look at next char without consuming
parser_peek2_character()     // Look 2 chars ahead
parser_peek3_character()     // Look 3 chars ahead
parser_next_character()      // Consume and return next char
parser_undo_character()      // Go back one character
parser_nl()                  // Consume newline, increment lineNumber

// Grab text until...
parser_grab_text_until_number_end(p)        // 123, 3.14
parser_grab_text_until_identifier_end(p)    // variableName
parser_grab_text_until_keypath_end(p)       // foo.bar.baz[key]
parser_grab_text_until_selector_end(p)      // method:name:parts
parser_grab_text_until_quote(p)             // "string contents"
parser_grab_text_until_scion_start(p)       // {{ or {% or {#
parser_skip_text_until_scion_end(p, type)   // skip until }} or %} or #}
parser_grab_text_until_command(p, "endif")  // Block terminators

// Whitespace handling
parser_skip_whitespace(p)      // Skip spaces/tabs (not newlines)
parser_skip_whitespace_to_scion_comment_or_after_newline(p)
parser_skip_whitespace_until_after_newline(p)  // Skip to next line
parser_skip_whitespace_and_comments_always(p)
parser_skip_after_newline(p)   // Consume newline and skip
```

---

## Key Parsing Patterns

### 1. Checkpointing/Rewinding
```c
parser_memo memo;
parser_memorize(p, &memo);      // Save current position
// ... try parsing ...
if (/* parsing failed */)
    parser_recall(p, &memo);    // Restore position and retry
```

### 2. Getting Parsed Text
```c
// Parser maintains a "memo" of where grab started
parser_grab_text_until_number_end(p);
NSString *s = parser_get_string(p);   // Extract [memo.curr..p->curr]
```

### 3. Memo Stack Approach
The parser uses multiple memos:
- `memo`: General position tracking
- `memo_scion`: Position of scion tag start (for error recovery)
- `memo_interesting`: Position of interesting content (for error messages)

### 4. Line Tracking
- Line numbers tracked throughout parsing
- Parser adjusts memos to end-of-line for comments/commands
- Used for error reporting with accurate line numbers

---

## Special Features

### 1. Macro Expansion
Macros defined with `{% macro name(param1, param2) %} ... {% endmacro %}`
- Stored in `parser->tables.macroTable`
- Expanded inline when called: `name(arg1, arg2)`
- Parameters become definitions during expansion
- Body is recursively parsed

### 2. Block Inheritance (extends)
```
Child template: {% extends "base.html" %}
Base template:  {% block content %} ... {% endblock %}
  
Result: Named blocks in child override/supplement base blocks
```

### 3. Include/Requires
```
{% includes "file.html" %}       // Include and parse inline
{% requires "file.html" %}       // Track as dependency
```
- Files searched in searchPath array
- Supports environment-variable-driven includes when `MULLESCION_ALLOW_GETENV_INCLUDES` is enabled: an **unquoted identifier** after `includes`/`extends` is treated as an environment-variable name and `getenv(identifier)` is used as the filename.

### 4. Verbatim Blocks
```
{% verbatim %}
  {{ this }} {% will %} be {# ignored #}
{% endverbatim %}
```
Output as literal text without parsing.

### 5. Filter/Apply (Output Modifiers)
```
{% filter capitalize %}
  some text
{% endfilter %}
```
Apply transformations to captured output.

---

## Parser State Machine for Template Tags

### Recognition Pattern
```
Plain text → Look for {{ or {% or {#
              ├─ {{ → expression
              ├─ {% → command  
              └─ {# → comment
```

### Macro Type Detection
```c
typedef enum {
    eof        = -1,  // End of input
    expression = 0,   // {{ ... }}
    command    = 1,   // {% ... %}
    comment    = 2,   // {# ... #}
    garbage    = 3    // Invalid
} macro_type;
```

---

## Object Model (AST)

Every parsed element becomes a `MulleScionObject`:

```
MulleScionObject (base class)
├─ Type predicates:
│  ├─ isTemplate, isVariable, isFunction, isMethod
│  ├─ isIf, isElse, isEndIf, isFor, isEndFor, isWhile, isEndWhile
│  ├─ isBlock, isParentBlock, isEndBlock
│  ├─ isPipe, isDot, isIndexing
│  └─ ...
│
└─ Chain structure:
   ├─ next_ pointer for linked list
   ├─ lineNumber_ for debugging
   └─ Subclasses override with specific data
```

### Value Objects
```
MulleScionValueObject extends MulleScionObject
├─ value_ (NSObject *)
└─ Subtypes:
   ├─ MulleScionNumber (NSNumber *value)
   ├─ MulleScionString (NSString *value)
   ├─ MulleScionVariable (NSString *identifier)
   ├─ MulleScionArray (NSArray *array)
   ├─ MulleScionDictionary (NSDictionary *dict)
   ├─ MulleScionMethod (target, selector, arguments)
   ├─ MulleScionFunction (identifier, arguments)
   └─ ... (many expression types)
```

---

## Error Handling

### Error Reporting Flow
```
parser_error(p, "format", args...)
  ↓
Build parser_error_info struct:
  - parser pointer
  - fileName
  - lineNumber
  - columnNumber (from parser_diagnostic_columnNumber)
  - message
  - line (from parser_diagnostic_line)
  ↓
Call -parserError: callback (Objective-C)
  ↓
MulleScionParser delegates to registered handler
```

### Error Recovery
- Warnings don't stop parsing (`parser_warning()`)
- Errors print diagnostics but continue if `ignoreErrors == YES`
- Parser tries to recover by repositioning (`parser_recall()`)

---

## Environment Variables

Parsed in `parser_init()`:

| Var | Flag | Purpose |
|-----|------|---------|
| `MULLESCION_ALLOW_GETENV_INCLUDES` | 0x01 | Allow envvar-name includes: if `{% includes IDENT %}` (or `{% extends IDENT %}`) uses an unquoted identifier and `getenv(IDENT)` returns a value, that value is used as the filename |
| `MULLESCION_NO_HASHBANG` | 0x02 | Don't skip `#!/...` first line |
| `MULLESCION_VERBATIM_INCLUDE_HASHBANG` | 0x04 | Preserve hashbang in included files |
| `MULLESCION_DUMP_COMMANDS` | 0x08 | Print `fprintf(stderr, ...)` for parsed commands |
| `MULLESCION_DUMP_EXPRESSIONS` | 0x10 | Print expressions |
| `MULLESCION_DUMP_MACROS` | 0x40 | Print macro expansions |

---

## File Organization

| File | Purpose | Lines |
|------|---------|-------|
| `MulleScionParser.h` | Main parser class interface | 106 |
| `MulleScionParser.m` | Parser class implementation | 425 |
| `MulleScionParser+Parsing.h` | Parsing extension interface | 81 |
| `MulleScionParser+Parsing.m` | **Core C parser** | **3,710** |
| `MulleScionObjectModel.h` | AST node base classes | 300+ |
| `MulleScionObjectModel.m` | AST node implementations | 1000+ |
| `MulleScionObjectModel+MacroExpansion.m` | Macro handling | 700+ |
| `MulleScionObjectModel+Printing.m` | Template output generation | 2300+ |
| `MulleScionParser+Parsing.m` | Main parsing logic | 3,710 |

---

## Parsing Process Summary

```
┌─────────────────────────────────────────────────────────┐
│ 1. Load data, create parser struct                      │
│    parser_init()                                        │
└─────────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────────┐
│ 2. Skip initial hashbang if present                     │
│    parser_skip_initial_hashbang_line_if_present()       │
└─────────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────────┐
│ 3. Main loop: _parser_next_object()                     │
│                                                         │
│    for each object in template:                         │
│      a) Grab plain text (if any)                        │
│      b) Check tag type: {{ vs {% vs {#                 │
│      c) Dispatch to appropriate parser                  │
│      d) Create MulleScionObject node                    │
│      e) Link into tree (via next_ pointers)             │
└─────────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────────┐
│ 4. Return populated MulleScionTemplate tree             │
│    Ready for execution/printing                         │
└─────────────────────────────────────────────────────────┘
```

---

## Key Insights

1. **Embedded C Parser**: Despite being an Objective-C project, the actual parsing logic is pure C (~3,700 lines of static functions)

2. **Manual Tokenization**: No lexer/scanner generator - all character-level parsing is manual

3. **Recursive Descent**: Expression and command parsing is recursive; expression operator handling is right-recursive and relies on AST-based parenthesis checks (no full precedence ladder)

4. **Position Checkpointing**: Extensively uses position memos for lookahead and error recovery

5. **Linked List AST**: Parsed objects form a linked list (via `next_` pointer) rather than a tree

6. **Callback Architecture**: Error/warning reporting uses C-style function pointers that call back to Objective-C methods

7. **Feature Flags**: Environment variables control debug output and feature behavior

8. **Template Inheritance**: Supports Twig-like `extends` and `block` for template inheritance

9. **Macro System**: Full macro support with parameter substitution and recursive expansion

10. **Line Number Tracking**: Careful line number maintenance throughout parsing for accurate error diagnostics

