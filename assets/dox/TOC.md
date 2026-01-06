# MulleScion Library Documentation for AI

## 1. Introduction & Purpose

**MulleScion** is a powerful Objective-C template engine inspired by Django/Twig templates, enabling dynamic HTML/text generation with variable substitution, conditionals, loops, and macro support. It parses template syntax and renders output with data provided via context objects implementing the `MulleScionDataSource` protocol.

This library is particularly useful for:
- Generating HTML dynamically from templates
- Building email templates with variable content
- Creating code generators
- Web application templating
- Report generation
- Configuration file templates with dynamic values

## 2. Key Concepts & Design Philosophy

- **Django/Twig-like Syntax**: Familiar `{{ }}` for variables and `{% %}` for control flow
- **Objective-C Integration**: Call ObjC methods directly in templates via Key Value Coding
- **Data Source Pattern**: Flexible context via objects implementing MulleScionDataSource
- **Template Files**: Load templates from files with optional include paths
- **No Arithmetic**: By design, no arithmetic or bitwise operations in templates
- **NSInvocation-based**: Method calls use NSInvocation (limitations with varargs and structs)

## 3. Core API & Data Structures

### Template Rendering (Convenience Methods)

The easiest way to use MulleScion is via the convenience category methods on `MulleScionTemplate`:

#### Render from File with Data Source

```objc
+ (NSString *) descriptionWithTemplateFile:(NSObject <MulleScionStringOrURL> *)location
                                dataSource:(id <MulleScionDataSource>)dataSource
```
- **location**: File path (NSString) or NSURL to template
- **dataSource**: Object providing template variables (implements MulleScionDataSource)
- Returns: Rendered template as NSString
- **Most Common Method** - Use this for typical template rendering

#### Render from UTF-8 String

```objc
+ (NSString *) descriptionWithUTF8Template:(char *)s
                                dataSource:(id <MulleScionDataSource>)dataSource
                                searchPath:(NSArray *)searchPath
```
- **s**: UTF-8 C string containing template
- **dataSource**: Context object
- **searchPath**: Directories to search for included templates
- Returns: Rendered template as NSString

#### Render with Local Variables

```objc
+ (NSString *) descriptionWithTemplateFile:(NSObject <MulleScionStringOrURL> *)location
                                dataSource:(id <MulleScionDataSource>)dataSource
                                searchPath:(NSArray *)searchPath
                            localVariables:(id <MulleScionLocals>)locals
```
- Adds local variables that override data source values
- **locals**: MulleScionLocals object for template-local variables

### Parser: `MulleScionParser` (Low-level API)

If you need more control, use the parser directly:

- `+ (MulleScionParser *) parserWithContentsOfFile:(NSString *)fileName searchPath:(NSArray *)searchPath`
  - Create parser from template file
  - Returns MulleScionParser object

- `+ (MulleScionParser *) parserWithUTF8String:(char *)s searchPath:(NSArray *)searchPath`
  - Create parser from UTF-8 C string
  - Returns MulleScionParser object

- `- (MulleScionTemplate *) template`
  - Parse and return template object
  - Can be expensive; cache the result

### MulleScionDataSource Protocol

Objects passed as `dataSource` must implement this protocol:

```objc
@protocol MulleScionDataSource
- (id) mulleDescriptionForScionKeyPath:(NSString *)keyPath;
@end
```

**Required Methods:**
- `mulleDescriptionForScionKeyPath:` - Return value for a key path
  - **keyPath**: Variable name or key path (e.g., "user.name")
  - Returns: NSString, NSNumber, NSArray, NSDate, or any object
  - Return nil for missing keys

**Key Points:**
- Objects returned should be NSString, NSNumber, NSArray, NSDictionary, NSDate, etc.
- Key paths use dot notation: `user.profile.email`
- Access object properties via Key Value Coding
- Can return any NSObject subclass

### Template Syntax

#### Variable Substitution
```twig
{{ variable }}                    # Output variable
{{ object.property }}             # Nested property
{{ [NSDate date] }}               # Call ObjC method
```

#### Control Flow
```twig
{% if condition %}
  ...content...
{% else %}
  ...alternative...
{% endif %}

{% for item in collection %}
  ...content...
{% empty %}
  ...no items...
{% endfor %}
```

#### Filters (Limited)
```twig
{{ variable|upper }}              # Some built-in filters
```

#### Macros and Defines
```twig
{% define name %}value{% enddefine %}
{{ name }}
```

## 4. Performance Characteristics

- **Parsing**: O(n) single pass through template
- **Rendering**: O(n + m) where n = template size, m = KVC lookups
- **Memory**: Output string allocated once
- **Typical**: < 50ms for 100 KB template
- **Caching**: Can cache parsed templates for repeated rendering

## 5. AI Usage Recommendations & Patterns

### Pattern 1: Simple Variable Substitution (Most Common)

Follow the README example exactly:

```objc
// Create a data source object that implements MulleScionDataSource
@interface MyDataSource : NSObject <MulleScionDataSource>
@end

@implementation MyDataSource
- (id) mulleDescriptionForScionKeyPath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"name"]) return @"Alice";
    if ([keyPath isEqualToString:@"count"]) return @42;
    return nil;
}
@end

// Render template
MyDataSource *data = [[MyDataSource alloc] init];
NSString *output = [MulleScionTemplate descriptionWithTemplateFile:@"template.scion"
                                                         dataSource:data];
printf("%s", [output UTF8String]);
[data release];
```

### Pattern 2: Dictionary-Based Context

Use NSDictionary as data source via KVC:

```objc
NSDictionary *context = @{
    @"name": @"Bob",
    @"email": @"bob@example.com",
    @"items": @[@"item1", @"item2"]
};

NSString *output = [MulleScionTemplate descriptionWithTemplateFile:@"template.scion"
                                                         dataSource:context];
```

### Pattern 3: Complex Objects

Pass custom objects that respond to KVC:

```objc
@interface User : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@end

User *user = [[User alloc] init];
user.name = @"Charlie";
user.email = @"charlie@example.com";

NSString *output = [MulleScionTemplate descriptionWithTemplateFile:@"template.scion"
                                                         dataSource:user];
[user release];
```

### Pattern 4: Method Calls in Templates

Call ObjC methods directly:

Template:
```twig
Processed on: {{ [NSDate date] }}
Process name: {{ [[NSProcessInfo processInfo] processName] }}
```

Works if the method returns basic types or NSObject subclasses.

### Common Pitfalls

- **No Arithmetic**: Can't do `{{ count + 1 }}` - No math in templates
- **Struct Limitations**: NSInvocation can't handle C structs well
- **VarArgs Methods**: Methods with variable arguments won't work
- **Missing Keys**: Return nil, template outputs nothing (silent fail)
- **Performance**: Large templates can be slow - consider caching parsed results
- **Variable Arguments**: `objc_msgSend` limitations apply

## 6. Integration Examples

### Example 1: Email Template

```objc
// Template file: email.scion
@"Dear {{ recipient.name }},\n\n"
@"Thank you for your order #{{ order.id }}.\n"
@"Total: ${{ order.total }}\n\n"
@"Items:\n"
@"{% for item in order.items %}"
@"  - {{ item.name }}: ${{ item.price }}\n"
@"{% endfor %}"

// Usage
NSDictionary *order = @{
    @"id": @"12345",
    @"total": @"99.99",
    @"items": @[
        @{@"name": @"Widget", @"price": @"29.99"},
        @{@"name": @"Gadget", @"price": @"70.00"}
    ]
};

NSDictionary *context = @{
    @"recipient": @{@"name": @"Alice"},
    @"order": order
};

NSString *email = [MulleScionTemplate descriptionWithTemplateFile:@"email.scion"
                                                       dataSource:context];
```

### Example 2: HTML Report

```objc
NSString *html = [MulleScionTemplate descriptionWithTemplateFile:@"report.html"
                                                      dataSource:self];

// In your class implementing MulleScionDataSource
- (id) mulleDescriptionForScionKeyPath:(NSString *)keyPath
{
    if ([keyPath isEqualToString:@"title"]) return @"Sales Report";
    if ([keyPath isEqualToString:@"generatedAt"]) return [NSDate date];
    if ([keyPath isEqualToString:@"items"]) return self.reportItems;
    return nil;
}
```

### Example 3: Configuration File

```objc
NSString *config = [MulleScionTemplate descriptionWithTemplateFile:@"config.template"
                                                         dataSource:appSettings];
[config writeToFile:@"/etc/app.conf" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
```

### Example 4: Dynamic Class Generation

```objc
NSString *sourceCode = [MulleScionTemplate descriptionWithTemplateFile:@"class.m.template"
                                                            dataSource:classDefinition];
```

## 7. Template Syntax Details

### Variables and Expressions

```twig
{{ foo }}                         # Variable
{{ foo.bar }}                     # Property access
{{ foo.0 }}                       # Array index
{{ [obj method] }}                # Method call
{{ [obj method:arg] }}            # Method with argument
```

### Control Structures

```twig
{% if foo %}                      # if
{% else %}                        # else
{% endif %}

{% for item in items %}           # for loop
  {{ item }}
{% empty %}                       # Optional: when empty
  No items
{% endfor %}
```

### Filters

Limited filter support (similar to original Twig):

```twig
{{ text|upper }}                  # Uppercase
{{ text|lower }}                  # Lowercase
```

## 8. Dependencies

- **MulleFoundation** - NSString, NSDictionary, NSArray, NSURL
- **mulle-objc** (runtime)
- Standard C library

## 9. Limitations (By Design)

- **No Arithmetic**: No `+`, `-`, `*`, `/` operators
- **No Bitwise Operators**: No `&`, `|`, `^` etc.
- **No Operator Precedence**: Use parentheses for clarity
- **Struct Handling**: C structs may not work via NSInvocation
- **Variable Arguments**: varargs methods not supported
- **No Command Execution**: No subprocess calls or system integration
- **No Comment Syntax**: No way to add comments in templates

## 10. Standards & References

- **Inspired by**: Django, Twig template engines
- **Method Dispatch**: Uses NSInvocation for ObjC calls
- **Key Value Coding**: Uses KVC for property access

## 11. Quick Start

1. Create data source object or use NSDictionary
2. Create template file with `.scion` extension
3. Call `descriptionWithTemplateFile:dataSource:` (the convenience method)
4. Output the returned NSString

```objc
NSString *result = [MulleScionTemplate descriptionWithTemplateFile:@"my.scion"
                                                         dataSource:myData];
printf("%s\n", [result UTF8String]);
```

## 12. Version Information

MulleScion version macro: `MULLE_SCION_VERSION`
Format: `(major << 20) | (minor << 8) | patch`

