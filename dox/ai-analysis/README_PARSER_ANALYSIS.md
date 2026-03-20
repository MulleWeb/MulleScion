# MulleScion C Parser - Complete Analysis

## Overview

I have thoroughly analyzed the **MulleScion template engine** parser, a sophisticated Twig-like template system written in Objective-C with an embedded C parser core. This directory contains comprehensive documentation of the parser architecture, functions, and design patterns.

## Quick Facts

- **Project**: MulleScion Template Engine
- **Location**: `/home/src/srcO/MulleWeb/MulleScion/`
- **Parser Size**: ~3,710 lines of C code
- **Language**: Objective-C (with embedded C parser)
- **Type**: Template Engine Library
- **Total Project**: 63 source files

## Documentation Files

### 1. **parser_analysis.md** (20KB)
Comprehensive technical reference including:
- Complete architecture overview
- Parser state machine structure
- All 100+ parsing functions documented
- Template syntax reference
- Design patterns and special features
- Environment variables
- Parsing process summary

**Use this for**: Deep technical understanding, function reference

### 2. **PARSER_SUMMARY.txt** (14KB)
Executive summary with:
- What the parser does
- Key architectural patterns (6 major patterns)
- Core functions organized by category
- Parser state structure
- Environment flags
- AST node types
- File organization
- Special features (macros, inheritance, etc.)

**Use this for**: Quick reference, overview

### 3. **PARSER_VISUAL_GUIDE.txt** (19KB)
Visual reference with:
- Input → parsing → output flow diagram
- Operator precedence hierarchy
- Template syntax tree
- Command dispatch table
- Parser state checkpoint system
- Character-level tokenization patterns
- Error reporting flow
- Whitespace handling
- Macro expansion sequence
- Template inheritance example
- Line number tracking

**Use this for**: Understanding flow, visual learners, patterns

## Key Findings

### Architecture
```
MulleScionParser (ObjC)
    ↓ delegates to ↓
C Parser (100+ static functions)
    ↓ produces ↓
MulleScionObject Tree (linked-list AST)
```

### Core Capabilities

**Template Syntax**:
- `{{ expr }}` - Expression output
- `{% command %}` - Commands (if, for, block, macro, etc.)
- `{# comment #}` - Comments
- Plain text - Literal output

**Expression Types**:
- Literals (numbers, strings, booleans)
- Collections (@arrays, @dicts)
- Keypaths and subscripting
- Operators (arithmetic, logical, comparison, ternary)
- Function and method calls
- Special keywords (selector, not, parent)

**Commands**:
- Control flow (if/else, for, while)
- Template structure (block, extends, parent)
- Macros (definition & calling)
- Includes (includes, requires)
- Variables (set, define)
- Filters (filter, apply)
- Special (verbatim, log)

### Design Patterns

1. **Embedded C Parser** - Pure C implementation in Objective-C class
2. **Recursive Descent** - Expression parsing is recursive, but there is **no full precedence ladder** (parentheses are enforced via AST `precedence`/`needsParenthesis` checks)
3. **Position Checkpointing** - Save/restore for lookahead
4. **Dispatch Table** - Commands mapped via opcodes
5. **Callback Bridge** - C→ObjC error handling
6. **Symbol Tables** - For macros, blocks, definitions

### Key Functions

**Main Parser Loop**:
- `parser_init()` - Initialize parser
- `_parser_next_object()` - Main parsing state machine
- `parser_grab_text_until_scion_start()` - Find template tags

**Expressions** (~20 functions):
- `parser_do_expression()` / `_parser_do_expression()` - Unary parse + right-recursive operator attachment (no binary arithmetic)
- `parser_do_number/string/identifier/method/function/selector()`

**Commands** (~30 functions):
- `parser_do_command()` - Main dispatcher
- `parser_do_if/for/while/block/macro/includes/extends/filter()`

**Character I/O**:
- `parser_peek_character()` - Look ahead
- `parser_next_character()` - Consume & track
- `parser_grab_text_until_*()` - Tokenization

**Error Handling**:
- `parser_error/warning()` - With full context
- `parser_diagnostic_columnNumber/line()`

## File Organization

```
src/
├─ MulleScionParser.h (106 lines) - Public API
├─ MulleScionParser.m (425 lines) - ObjC wrapper
├─ MulleScionParser+Parsing.h (81 lines) - Extension interface
├─ MulleScionParser+Parsing.m (3,710 lines) ⭐ CORE PARSER
├─ MulleScionObjectModel.h (300+ lines) - AST definitions
├─ MulleScionObjectModel.m (1,000+ lines) - AST implementations
└─ MulleScionObjectModel+*.m (3,000+ lines) - Extensions
```

## How the Parser Works

### Parsing Phases

1. **Initialization**
   - Load data into buffer
   - Initialize parser state
   - Set up symbol tables
   - Load environment flags

2. **Main Loop**
   - Scan for template tags: `{{ `, `{% `, `{# `
   - Grab plain text before tag
   - Determine tag type
   - Dispatch to appropriate handler

3. **Tag Processing**
   - **Expression** (`{{ ... }}`): Parse unary + attach operators (parentheses required in some cases; no binary arithmetic)
   - **Command** (`{% ... %}`): Parse and dispatch
   - **Comment** (`{# ... #}`): Skip and continue

4. **AST Construction**
   - Create MulleScionObject nodes
   - Link via `next_` pointer
   - Track source line numbers

5. **Return**
   - Populated MulleScionTemplate tree
   - Ready for execution/printing

### Parsing Strategy

**Recursive Descent**: Each expression/command level has a dedicated parser function
**Operator handling**: No full precedence ladder; the parser attaches operators right-recursively and uses AST `precedence`/`needsParenthesis` checks to require parentheses
**Position Memos**: Save/restore for backtracking and lookahead
**Character Scanning**: Manual tokenization with position tracking
**Error Recovery**: Callbacks for flexible error handling

## Special Features

### Template Inheritance
```
Base: {% block content %} DEFAULT {% endblock %}
Child: {% extends "base" %} + {% block content %} CUSTOM {% endblock %}
Result: CUSTOM replaces DEFAULT
```

### Macros
```
{% macro greet(name) %}Hello {{ name }}!{% endmacro %}
{{ greet("World") }} → "Hello World!"
```

### Position Checkpointing
```
parser_memo saved;
parser_memorize(p, &saved);
// try parsing...
if (failed) parser_recall(p, &saved); // retry
```

## Environmental Variables

Controls parser behavior:
- `MULLESCION_ALLOW_GETENV_INCLUDES` - Allow envvar-name includes: `{% includes IDENT %}` / `{% extends IDENT %}` resolves `IDENT` via `getenv(IDENT)` (unquoted identifiers only)
- `MULLESCION_NO_HASHBANG` - Don't skip #!/...
- `MULLESCION_DUMP_COMMANDS` - Print commands during parsing
- `MULLESCION_DUMP_EXPRESSIONS` - Print expressions
- `MULLESCION_DUMP_MACROS` - Print macro expansions

## AST Node Types (Abbreviated)

```
MulleScionObject (base)
├─ MulleScionTemplate (root)
├─ MulleScionPlainText
├─ MulleScionExpression (abstract)
│  ├─ MulleScionNumber, String, Variable, Array, Dictionary
│  ├─ MulleScionMethod, Function, Selector, Not
│  └─ ... (more)
├─ MulleScionCommand (abstract)
│  ├─ MulleScionIf, Else, EndIf, For, While, Block
│  ├─ MulleScionMacro, Filter, Include, Extends
│  └─ ... (more)
```

## Code Statistics

- **Core parser implementation**: 3,710 lines (`src/MulleScionParser+Parsing.m`)
- **Parser wrapper + headers**: 4,322 lines total (`MulleScionParser.h/.m` + `MulleScionParser+Parsing.h/.m`)
- **Total Objective-C sources under `src/`**: ~15.5K lines (`.m` + `.h`)
- **Total project source files under `src/`**: 63 (`.m` + `.h`)

## Study Recommendations

### For Understanding Parser Architecture
1. Start with `PARSER_SUMMARY.txt` for overview
2. Read the "KEY ARCHITECTURAL PATTERNS" section
3. Study `_parser_next_object()` in the code
4. Understand the memo/checkpoint system

### For Understanding Expression Parsing
1. Review expression operator-handling notes in `PARSER_VISUAL_GUIDE.txt` (no full precedence ladder)
2. Study `parser_do_expression()` function hierarchy
3. Understand recursive descent pattern

### For Understanding Command Parsing
1. Review command dispatch table in `PARSER_VISUAL_GUIDE.txt`
2. Study `parser_do_command()` dispatcher
3. Examine specific handlers like `parser_do_if()`, `parser_do_for()`

### For Understanding Error Handling
1. Review error reporting flow in `PARSER_VISUAL_GUIDE.txt`
2. Study `parser_error()` and `parser_warning()` functions
3. Understand callback bridge architecture

## Key Takeaways

1. **Well-Structured Design**: Clean separation of concerns
2. **Manual Implementation**: All parsing done without generators
3. **Careful Tracking**: Line numbers and positions throughout
4. **Flexible Error Handling**: Callback-based for extensibility
5. **Symbol Management**: Macros, blocks, and definitions tracked
6. **Feature Flags**: Environment variables for debugging
7. **Performance-Conscious**: Minimal copying, direct pointers

## The Parser in Action

```
INPUT:
  Hello {{ name }}!
  {% if show_items %}
    Items: {% for item in items %}{{ item }}{% endfor %}
  {% endif %}

PARSING:
  1. "Hello " → MulleScionPlainText
  2. {{ name }} → MulleScionVariable("name")
  3. "!\n" → MulleScionPlainText
  4. {% if show_items %} → MulleScionIf
  5. "Items: " → MulleScionPlainText
  6. {% for item in items %} → MulleScionFor
  7. {{ item }} → MulleScionVariable("item")
  8. {% endfor %} → MulleScionEndFor
  9. {% endif %} → MulleScionEndIf

RESULT:
  MulleScionTemplate (linked-list of above nodes)
  Ready for execution and output generation
```

## Additional Resources

- **Source Code**: `/home/src/srcO/MulleWeb/MulleScion/src/`
- **Main Parser**: `MulleScionParser+Parsing.m` (3,710 lines)
- **AST Definitions**: `MulleScionObjectModel.h`
- **AST Implementation**: `MulleScionObjectModel.m`

---

Created: 2025-03-19
Analysis Depth: Comprehensive (architecture, functions, patterns, flow)
Documentation: 53KB across 3 detailed files
