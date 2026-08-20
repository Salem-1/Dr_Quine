Absolutely. Treat this as a **complete macro course**, not a reference manual. Read it in order and actually run the examples with:

```bash
gcc -std=c23 -Wall -Wextra -pedantic file.c
```

And whenever a macro confuses you:

```bash
gcc -std=c23 -E -P file.c
```

That second command is your macro X-ray machine.

---

# C Macros: Zero → Crazy Advanced

## Part 0 — The one mental model you need

A macro is **not a function**.

The preprocessor runs before normal C compilation.

You write:

```c
#define SIZE 100

int array[SIZE];
```

The preprocessor roughly transforms it into:

```c
int array[100];
```

Then the compiler compiles the transformed C.

Think:

```text
source.c
   ↓
preprocessor
   ↓
expanded C
   ↓
compiler
   ↓
machine code
```

The preprocessor mostly understands **tokens**, not C types or semantics.

It does not really understand:

```text
int
struct
enum
typedef
variables
functions
scope
sizeof
```

It sees tokens and applies replacement rules.

That explains almost every weird macro behavior.

---

# Part 1 — Object-like macros

Basic syntax:

```c
#define NAME replacement
```

Example:

```c
#define BUFFER_SIZE 1024
#define PI 3.141592653589793
```

Usage:

```c
char buffer[BUFFER_SIZE];

double circumference = 2 * PI * radius;
```

Macros don't have to contain numbers:

```c
#define ERROR_MESSAGE "Something went wrong"
#define INTEGER_TYPE unsigned long
```

Then:

```c
INTEGER_TYPE value = 100;
```

becomes:

```c
unsigned long value = 100;
```

That's your first important lesson:

> Macro replacement works on tokens, not values.

---

# Part 2 — `#undef`

You can remove a macro:

```c
#define VALUE 100

#undef VALUE

#define VALUE 200
```

Useful when temporarily redefining something, especially with X-macros later.

---

# Part 3 — Function-like macros

Syntax:

```c
#define NAME(parameters) replacement
```

Important: when **defining** a function-like macro, there must be no space here:

```c
#define ADD(a, b) ((a) + (b))
```

Not:

```c
#define ADD (a, b) ...
```

The second one defines an object-like macro named `ADD`.

Usage:

```c
int x = ADD(10, 20);
```

Expansion:

```c
int x = ((10) + (20));
```

---

# Part 4 — Parentheses: your first major rule

Consider:

```c
#define DOUBLE(x) x + x
```

Then:

```c
int result = 3 * DOUBLE(4);
```

Expansion:

```c
int result = 3 * 4 + 4;
```

That's:

```text
12 + 4 = 16
```

But you wanted:

```text
3 × 8 = 24
```

Correct:

```c
#define DOUBLE(x) ((x) + (x))
```

Now:

```c
3 * DOUBLE(4)
```

becomes:

```c
3 * ((4) + (4))
```

Rule:

> Parenthesize every macro argument and normally parenthesize the entire expression.

Example:

```c
#define ADD(a, b) ((a) + (b))
#define MULTIPLY(a, b) ((a) * (b))
```

---

# Part 5 — Why macros can be dangerous

Consider:

```c
#define SQUARE(x) ((x) * (x))
```

Fine:

```c
SQUARE(5)
```

→

```c
((5) * (5))
```

But:

```c
int i = 5;

int x = SQUARE(i++);
```

Expansion:

```c
int x = ((i++) * (i++));
```

You've now modified `i` multiple times without proper sequencing.

Bad.

Another famous example:

```c
#define MAX(a, b) ((a) > (b) ? (a) : (b))
```

Then:

```c
MAX(get_value(), other_value)
```

`get_value()` could execute twice.

So memorize:

> Never assume a macro argument is evaluated only once.

This is one reason normal functions are safer.

---

# Part 6 — Prefer inline functions when possible

Instead of:

```c
#define SQUARE(x) ((x) * (x))
```

you might use:

```c
static inline int square_int(int x)
{
    return x * x;
}
```

Now:

```c
square_int(i++);
```

increments `i` once.

Macros are useful when you need things functions cannot easily provide, such as:

```text
conditional compilation
stringifying source code
token generation
generic code generation
compile-time configuration
type-independent preprocessing
X-macros
```

---

# Part 7 — Multiline macros

Use `\`:

```c
#define SAY_HELLO()          \
    printf("Hello\n");       \
    printf("Welcome!\n")
```

Be careful: the backslash must continue the line.

But this macro has another problem.

---

# Part 8 — The multiple-statement trap

Consider:

```c
#define LOG_ERROR()           \
    printf("Error\n");        \
    save_log()
```

Now:

```c
if (failed)
    LOG_ERROR();
else
    recover();
```

Expansion:

```c
if (failed)
    printf("Error\n");

save_log();
else
    recover();
```

Broken.

---

# Part 9 — `do { } while (0)`

The standard solution:

```c
#define LOG_ERROR()           \
    do {                      \
        printf("Error\n");    \
        save_log();           \
    } while (0)
```

Now:

```c
if (failed)
    LOG_ERROR();
else
    recover();
```

works properly.

Why?

Because:

```c
do {
    ...
} while (0);
```

acts syntactically like one statement.

This is one of the most important macro idioms in C.

Use:

```c
#define STATEMENT_MACRO(...) \
    do {                     \
        ...                  \
    } while (0)
```

---

# Part 10 — Do not put the caller's `;` in the macro

Write:

```c
#define RESET(x) \
    do {         \
        (x) = 0; \
    } while (0)
```

User writes:

```c
RESET(value);
```

Don't write:

```c
#define RESET(x) \
    do {         \
        (x) = 0; \
    } while (0);
```

The semicolon belongs to the caller.

---

# Part 11 — Macro parameters are tokens

You can pass expressions:

```c
#define PRINT(x) printf("%d\n", (x))

PRINT(10 + 20);
```

Expansion:

```c
printf("%d\n", (10 + 20));
```

You can pass function calls:

```c
PRINT(get_value());
```

You can even pass types to macros:

```c
#define DECLARE(type, name) type name

DECLARE(int, score);
DECLARE(double, temperature);
```

Expands to:

```c
int score;
double temperature;
```

---

# Part 12 — Commas inside macro arguments

This works:

```c
#define TEST(x) something(x)

TEST(foo(1, 2));
```

The preprocessor knows the comma is inside parentheses.

It sees one argument:

```c
foo(1, 2)
```

But braces don't protect commas in the same way.

Something like:

```c
MACRO((struct Point){1, 2})
```

can cause preprocessing trouble depending on how the tokens are structured, because macro argument separation is fundamentally based on parenthesis nesting.

A useful trick is extra parentheses:

```c
MACRO(((struct Point){1, 2}))
```

Advanced lesson:

> The preprocessor understands parentheses for macro argument grouping, not full C syntax.

---

# Part 13 — Stringification: `#`

Here's where macros start doing things functions cannot.

```c
#define STRINGIFY_RAW(x) #x
```

Then:

```c
STRINGIFY_RAW(hello)
```

becomes:

```c
"hello"
```

And:

```c
STRINGIFY_RAW(hello world)
```

becomes roughly:

```c
"hello world"
```

Useful debugging macro:

```c
#define PRINT_INT(expr) \
    printf(#expr " = %d\n", (expr))
```

Usage:

```c
int x = 10;

PRINT_INT(x);
PRINT_INT(x + 20);
```

Output:

```text
x = 10
x + 20 = 30
```

Notice:

```c
#expr
```

captures the source expression as text.

---

# Part 14 — The first weird expansion rule

Look:

```c
#define VALUE 42
#define STRINGIFY_RAW(x) #x
```

What does this produce?

```c
STRINGIFY_RAW(VALUE)
```

Not:

```c
"42"
```

It produces:

```c
"VALUE"
```

Why?

Because an argument used directly with `#` is **not macro-expanded first**.

That's intentional.

---

# Part 15 — Two-layer stringification

Solution:

```c
#define STRINGIFY_RAW(x) #x
#define STRINGIFY(x) STRINGIFY_RAW(x)
```

Now:

```c
#define VALUE 42

STRINGIFY(VALUE)
```

Expansion conceptually:

```text
STRINGIFY(VALUE)

↓

STRINGIFY_RAW(42)

↓

"42"
```

Remember this pattern:

```c
#define STR_RAW(x) #x
#define STR(x) STR_RAW(x)
```

You'll use it constantly in advanced macro programming.

---

# Part 16 — Token pasting: `##`

`##` joins tokens.

```c
#define MAKE_NAME(a, b) a##b
```

Then:

```c
MAKE_NAME(hello, world)
```

becomes one token:

```c
helloworld
```

Example:

```c
#define VARIABLE(n) variable_##n
```

Then:

```c
int VARIABLE(1);
int VARIABLE(2);
```

expands to:

```c
int variable_1;
int variable_2;
```

---

# Part 17 — Two-layer token concatenation

Same problem as stringification.

```c
#define CAT_RAW(a, b) a##b
```

Suppose:

```c
#define NUMBER 5

CAT_RAW(value_, NUMBER)
```

may produce:

```c
value_NUMBER
```

because arguments adjacent to `##` aren't expanded normally first.

Correct:

```c
#define CAT_RAW(a, b) a##b
#define CAT(a, b) CAT_RAW(a, b)
```

Now:

```c
CAT(value_, NUMBER)
```

becomes:

```c
value_5
```

Memorize both:

```c
#define STR_RAW(x) #x
#define STR(x) STR_RAW(x)

#define CAT_RAW(a, b) a##b
#define CAT(a, b) CAT_RAW(a, b)
```

These are your two fundamental metaprogramming helpers.

---

# Part 18 — `##` must create a valid token

This is valid:

```c
CAT(foo, bar)
```

→

```c
foobar
```

This is valid:

```c
CAT(value_, 10)
```

→

```c
value_10
```

But don't randomly paste arbitrary punctuation/tokens.

Token pasting has to produce a valid preprocessing token.

---

# Part 19 — Predefined macros

Very useful ones include:

```c
__FILE__
__LINE__
__DATE__
__TIME__
__STDC__
__STDC_VERSION__
__STDC_HOSTED__
```

Example:

```c
printf("File: %s\n", __FILE__);
printf("Line: %d\n", __LINE__);
```

---

# Part 20 — Build a source-location logger

```c
#define LOG(message)                                   \
    do {                                               \
        fprintf(stderr, "%s:%d: %s\n",                 \
                __FILE__, __LINE__, (message));        \
    } while (0)
```

Usage:

```c
LOG("Connection failed");
```

Possible output:

```text
network.c:73: Connection failed
```

Very useful.

---

# Part 21 — `__func__`

Inside a function:

```c
void process(void)
{
    printf("%s\n", __func__);
}
```

prints:

```text
process
```

Important distinction:

`__func__` behaves like a predefined function-local identifier, not exactly like a normal preprocessor macro.

Combine it:

```c
#define TRACE()                                     \
    fprintf(stderr, "%s:%d %s()\n",                 \
            __FILE__, __LINE__, __func__)
```

---

# Part 22 — Variadic macros

Macros can accept any number of extra arguments.

```c
#define PRINT(...) printf(__VA_ARGS__)
```

Usage:

```c
PRINT("Hello\n");

PRINT("x = %d\n", x);

PRINT("%d %d %d\n", a, b, c);
```

`__VA_ARGS__` represents the variable arguments.

---

# Part 23 — Practical variadic logger

```c
#define LOG(...)                     \
    do {                             \
        fprintf(stderr, __VA_ARGS__); \
        fprintf(stderr, "\n");       \
    } while (0)
```

Usage:

```c
LOG("Starting");

LOG("value = %d", value);

LOG("x=%d y=%d", x, y);
```

---

# Part 24 — Named parameter + variadic arguments

```c
#define LOG_LEVEL(level, ...)            \
    do {                                 \
        fprintf(stderr, "[%s] ", level); \
        fprintf(stderr, __VA_ARGS__);    \
        fprintf(stderr, "\n");           \
    } while (0)
```

Usage:

```c
LOG_LEVEL("INFO", "Server started");

LOG_LEVEL("ERROR",
          "Connection failed: %d",
          error_code);
```

---

# Part 25 — The empty variadic problem

Old-style macro:

```c
#define LOG(format, ...) \
    fprintf(stderr, format, __VA_ARGS__)
```

This works:

```c
LOG("x = %d", x);
```

But:

```c
LOG("Hello");
```

could become:

```c
fprintf(stderr, "Hello", );
```

Bad.

---

# Part 26 — C23 `__VA_OPT__`

Modern solution:

```c
#define LOG(format, ...) \
    fprintf(stderr, format __VA_OPT__(,) __VA_ARGS__)
```

With:

```c
LOG("Hello");
```

`__VA_OPT__` disappears:

```c
fprintf(stderr, "Hello");
```

With:

```c
LOG("x = %d", x);
```

it produces:

```c
fprintf(stderr, "x = %d", x);
```

Think:

```c
__VA_OPT__(something)
```

means:

> emit `something` only if variadic arguments exist.

This is hugely useful in modern macro metaprogramming.

---

# Part 27 — Old GCC extension

You may encounter:

```c
#define LOG(format, ...) \
    fprintf(stderr, format, ##__VA_ARGS__)
```

GCC historically used the special `, ##__VA_ARGS__` trick to remove the comma when arguments were empty.

Understand it when reading old code.

For modern C23-oriented code, prefer:

```c
__VA_OPT__
```

---

# Part 28 — Conditional compilation

Basic:

```c
#define DEBUG

#ifdef DEBUG
printf("Debug enabled\n");
#endif
```

Or:

```c
#ifndef DEBUG
printf("Release mode\n");
#endif
```

---

# Part 29 — Compile-time configuration

You can compile:

```bash
gcc -DDEBUG main.c
```

Equivalent to having something like:

```c
#define DEBUG
```

available during preprocessing.

You can define a value:

```bash
gcc -DLOG_LEVEL=3 main.c
```

Then:

```c
#if LOG_LEVEL >= 3
    ...
#endif
```

---

# Part 30 — `#if`

```c
#define VERSION 3

#if VERSION >= 3
    /* compile this */
#else
    /* compile something else */
#endif
```

Supported operators include normal integer-expression operations such as:

```text
+
-
*
/
%
<
>
<=
>=
==
!=
&&
||
!
&
|
^
<<
>>
```

---

# Part 31 — `defined`

```c
#if defined(DEBUG)
#endif
```

or:

```c
#ifdef DEBUG
#endif
```

Multiple:

```c
#if defined(DEBUG) && defined(LOGGING)
#endif
```

---

# Part 32 — Unknown identifiers inside `#if`

This surprises beginners:

```c
#if SOMETHING
```

If `SOMETHING` is not defined as a macro, it normally becomes `0` during preprocessing evaluation.

So this behaves like:

```c
#if 0
```

That is why configuration code often uses:

```c
#if defined(FEATURE)
```

instead.

---

# Part 33 — Preprocessor doesn't know `sizeof`

You cannot normally do:

```c
#if sizeof(int) == 4
```

The preprocessor evaluates preprocessing integer expressions. It does not run the C type system.

Use C compile-time facilities instead:

```c
_Static_assert(sizeof(int) == 4,
               "32-bit int required");
```

Or C23 spelling:

```c
static_assert(sizeof(int) == 4,
              "32-bit int required");
```

---

# Part 34 — `#elif`

```c
#if PLATFORM == 1

#elif PLATFORM == 2

#else

#endif
```

C23 also has convenient forms such as:

```c
#elifdef FEATURE
```

and:

```c
#elifndef FEATURE
```

---

# Part 35 — Platform abstraction

Typical:

```c
#if defined(_WIN32)

#define PLATFORM_WINDOWS 1

#elif defined(__linux__)

#define PLATFORM_LINUX 1

#elif defined(__APPLE__)

#define PLATFORM_APPLE 1

#else

#error Unsupported platform

#endif
```

Then elsewhere:

```c
#if PLATFORM_LINUX
...
#endif
```

A good project centralizes these checks instead of scattering compiler-specific macros everywhere.

---

# Part 36 — `#error`

Force compilation to stop:

```c
#ifndef REQUIRED_FEATURE
#error REQUIRED_FEATURE must be defined
#endif
```

Another example:

```c
#if BUFFER_SIZE < 128
#error BUFFER_SIZE is too small
#endif
```

Very useful for configuration validation.

---

# Part 37 — Include guards

Header:

```c
#ifndef MY_LIBRARY_H
#define MY_LIBRARY_H

void library_run(void);

#endif
```

This prevents the same declarations from being processed repeatedly.

Names should be project-specific:

```c
#ifndef SUPERAPP_NETWORK_SOCKET_H
#define SUPERAPP_NETWORK_SOCKET_H
...
#endif
```

---

# Part 38 — Macro-generated `#include`

You can do:

```c
#define CONFIG_HEADER "project_config.h"

#include CONFIG_HEADER
```

This is useful in configurable libraries.

---

# Part 39 — Disabled macros

Suppose debugging is disabled.

Avoid merely:

```c
#define DEBUG_LOG(...)
```

A common robust form is:

```c
#define DEBUG_LOG(...) ((void)0)
```

Then:

```c
DEBUG_LOG("x = %d", x);
```

becomes:

```c
((void)0);
```

A valid statement-like expression.

---

# Part 40 — Debug/release logger

```c
#ifdef DEBUG

#define DEBUG_LOG(...)               \
    do {                             \
        fprintf(stderr, __VA_ARGS__); \
        fprintf(stderr, "\n");       \
    } while (0)

#else

#define DEBUG_LOG(...) ((void)0)

#endif
```

Calls disappear in release builds:

```c
DEBUG_LOG("value=%d", value);
```

---

# Part 41 — Assertions with stringification

```c
#define MY_ASSERT(condition)                              \
    do {                                                  \
        if (!(condition)) {                               \
            fprintf(stderr,                               \
                "Assertion failed: %s\n"                  \
                "File: %s\n"                              \
                "Line: %d\n",                             \
                #condition, __FILE__, __LINE__);          \
            abort();                                      \
        }                                                 \
    } while (0)
```

Usage:

```c
MY_ASSERT(pointer != NULL);
```

If false:

```text
Assertion failed: pointer != NULL
File: main.c
Line: 42
```

Again:

```c
#condition
```

turns the programmer's expression into text.

---

# Part 42 — Macro hygiene

Suppose:

```c
#define DO_WORK(x)          \
    do {                    \
        int temp = (x);     \
        process(temp);      \
    } while (0)
```

Potential collision:

```c
int temp = 100;

DO_WORK(temp);
```

Macro-local identifiers should have unusual names:

```c
#define DO_WORK(x)               \
    do {                         \
        int do_work_tmp_ = (x);  \
        process(do_work_tmp_);   \
    } while (0)
```

There's no perfect hygiene system in the C preprocessor.

Use project-specific names.

---

# Part 43 — Macro namespaces

This is terrible library design:

```c
#define MAX 100
#define ERROR 1
#define SUCCESS 0
```

Other headers might use those names.

Prefer:

```c
#define MYLIB_MAX_CONNECTIONS 100
#define MYLIB_ERROR 1
#define MYLIB_SUCCESS 0
```

Macros effectively live in a giant preprocessing namespace.

---

# Part 44 — Unique names with `__LINE__`

We have:

```c
#define CAT_RAW(a, b) a##b
#define CAT(a, b) CAT_RAW(a, b)
```

Then:

```c
#define UNIQUE(prefix) CAT(prefix, __LINE__)
```

Usage:

```c
int UNIQUE(temp_);
```

If on line 35:

```c
int temp_35;
```

Useful for macro-generated internals.

Problem:

```c
UNIQUE(x_);
UNIQUE(y_);
```

is fine on separate lines.

But two uses requiring uniqueness on the **same line** can collide.

---

# Part 45 — `__COUNTER__`

GCC, Clang, MSVC and others commonly support:

```c
__COUNTER__
```

It increases each time it is expanded.

Example:

```c
#define UNIQUE(prefix) CAT(prefix, __COUNTER__)
```

Could produce:

```c
temp_0
temp_1
temp_2
temp_3
```

Very useful.

But treat `__COUNTER__` as a compiler-supported extension unless your portability target explicitly guarantees it.

---

# Part 46 — Generate declarations

```c
#define DECLARE_INT(name) int name
```

Usage:

```c
DECLARE_INT(score);
DECLARE_INT(age);
```

Generate functions:

```c
#define DECLARE_GETTER(type, name) \
    type get_##name(void)
```

Usage:

```c
DECLARE_GETTER(int, score);
```

Expansion:

```c
int get_score(void);
```

Now we're doing actual **code generation**.

---

# Part 47 — Generate function definitions

```c
#define DEFINE_GETTER(type, name, variable) \
    type get_##name(void)                   \
    {                                       \
        return variable;                    \
    }
```

Example:

```c
static int player_score;

DEFINE_GETTER(int, score, player_score)
```

Expansion:

```c
int get_score(void)
{
    return player_score;
}
```

---

# Part 48 — X-macros: the gateway to serious macro programming

Imagine:

```c
enum Color {
    COLOR_RED,
    COLOR_GREEN,
    COLOR_BLUE
};
```

And separately:

```c
const char *names[] = {
    "RED",
    "GREEN",
    "BLUE"
};
```

Problem: two lists must stay synchronized.

Instead define **one master list**:

```c
#define COLOR_LIST \
    X(RED)          \
    X(GREEN)        \
    X(BLUE)
```

Now generate the enum.

```c
#define X(name) COLOR_##name,

enum Color {
    COLOR_LIST
};

#undef X
```

Expansion:

```c
enum Color {
    COLOR_RED,
    COLOR_GREEN,
    COLOR_BLUE,
};
```

Now use the same list again:

```c
#define X(name) #name,

static const char *color_names[] = {
    COLOR_LIST
};

#undef X
```

Expansion:

```c
static const char *color_names[] = {
    "RED",
    "GREEN",
    "BLUE",
};
```

One source of truth.

This pattern is called an **X-macro**.

---

# Part 49 — X-macros with multiple fields

Now we're getting serious.

```c
#define ERROR_LIST                                \
    X(NONE,       0, "No error")                  \
    X(IO,         1, "Input/output error")        \
    X(MEMORY,     2, "Out of memory")             \
    X(PERMISSION, 3, "Permission denied")
```

Generate enum:

```c
#define X(name, value, message) \
    ERROR_##name = value,

enum ErrorCode {
    ERROR_LIST
};

#undef X
```

Generate strings:

```c
#define X(name, value, message) \
    [ERROR_##name] = message,

static const char *error_messages[] = {
    ERROR_LIST
};

#undef X
```

Now:

```c
error_messages[ERROR_MEMORY]
```

gives:

```text
Out of memory
```

---

# Part 50 — X-macro command system

Master list:

```c
#define COMMAND_LIST                  \
    X(start,   "Start application")   \
    X(stop,    "Stop application")    \
    X(restart, "Restart application")
```

Generate functions:

```c
#define X(name, description) \
    void command_##name(void);

COMMAND_LIST

#undef X
```

Produces:

```c
void command_start(void);
void command_stop(void);
void command_restart(void);
```

Generate table:

```c
struct Command {
    const char *name;
    const char *description;
    void (*function)(void);
};

#define X(name, description)              \
    { #name, description, command_##name },

static const struct Command commands[] = {
    COMMAND_LIST
};

#undef X
```

Now your list generates:

```text
enums
strings
functions
tables
documentation metadata
serialization information
```

from a single definition.

X-macros are one of the best uses of the C preprocessor.

---

# Part 51 — Designated initializer generation

Master list:

```c
#define STATE_LIST \
    X(IDLE)         \
    X(RUNNING)      \
    X(ERROR)
```

Enum:

```c
#define X(name) STATE_##name,

enum State {
    STATE_LIST
};

#undef X
```

String table:

```c
#define X(name) [STATE_##name] = #name,

static const char *state_names[] = {
    STATE_LIST
};

#undef X
```

Then:

```c
printf("%s\n", state_names[STATE_RUNNING]);
```

prints:

```text
RUNNING
```

Very clean.

---

# Part 52 — `_Generic`: type-based compile-time selection

C11 introduced `_Generic`.

Not technically a preprocessor feature, but macros make it incredibly useful.

```c
#define TYPE_NAME(x) _Generic((x), \
    int: "int",                     \
    long: "long",                   \
    float: "float",                 \
    double: "double",               \
    default: "other")
```

Then:

```c
TYPE_NAME(10)
```

→ `"int"`

```c
TYPE_NAME(3.14)
```

→ `"double"`

---

# Part 53 — Type-generic functions

Write safe real functions:

```c
static inline int max_int(int a, int b)
{
    return a > b ? a : b;
}

static inline double max_double(double a, double b)
{
    return a > b ? a : b;
}
```

Then:

```c
#define MAX(a, b) _Generic(((a) + (b)), \
    int: max_int,                       \
    double: max_double                  \
)((a), (b))
```

Now:

```c
MAX(10, 20)
```

selects:

```c
max_int
```

And:

```c
MAX(1.5, 9.8)
```

selects:

```c
max_double
```

Why use:

```c
((a) + (b))
```

as the controlling expression?

Because C's usual arithmetic conversions can determine the combined type.

Important advantage:

`_Generic`'s controlling expression is not normally evaluated, so:

```c
MAX(i++, j++)
```

passes the actual operands to the selected inline function, where each is evaluated once.

That's much safer than:

```c
#define MAX(a,b) ...
```

duplicating arguments directly.

---

# Part 54 — Generic printing

```c
static inline void print_int(int x)
{
    printf("%d\n", x);
}

static inline void print_double(double x)
{
    printf("%f\n", x);
}

static inline void print_string(const char *x)
{
    printf("%s\n", x);
}
```

Macro:

```c
#define PRINT(x) _Generic((x), \
    int: print_int,            \
    double: print_double,      \
    char *: print_string,      \
    const char *: print_string \
)(x)
```

Then:

```c
PRINT(42);
PRINT(3.14);
PRINT("hello");
```

C now feels almost overloaded.

---

# Part 55 — Array-size macro

Classic:

```c
#define ARRAY_LEN(array) \
    (sizeof(array) / sizeof((array)[0]))
```

Example:

```c
int numbers[] = {10, 20, 30, 40};

size_t count = ARRAY_LEN(numbers);
```

→ `4`.

But:

```c
int *ptr = numbers;

ARRAY_LEN(ptr)
```

is wrong.

Why?

Because:

```c
sizeof(ptr)
```

is pointer size, not array size.

Never forget this limitation.

---

# Part 56 — Compound literal helpers

```c
struct Point {
    int x;
    int y;
};
```

Create:

```c
#define POINT(x_, y_) \
    ((struct Point){ .x = (x_), .y = (y_) })
```

Usage:

```c
struct Point p = POINT(10, 20);
```

Useful for small constructor-like interfaces.

---

# Part 57 — `offsetof`

Standard library:

```c
#include <stddef.h>
```

Then:

```c
struct Player {
    int health;
    double position;
};
```

You can do:

```c
offsetof(struct Player, position)
```

which gives the byte offset of `position` inside the struct.

This leads us to a famous systems macro.

---

# Part 58 — `container_of`

Suppose:

```c
struct Node {
    struct Node *next;
};

struct Player {
    int health;
    struct Node node;
};
```

You have:

```c
struct Node *node;
```

but want the containing:

```c
struct Player *
```

Classic concept:

```c
#define CONTAINER_OF(ptr, type, member) \
    ((type *)((char *)(ptr) - offsetof(type, member)))
```

Usage:

```c
struct Player *player =
    CONTAINER_OF(node, struct Player, node);
```

Memory:

```text
Player object

+----------------+
| health         |
+----------------+
| node           | ← ptr points here
+----------------+

subtract offsetof(Player, node)

↓

+----------------+
| Player start   |
+----------------+
```

This technique enables intrusive data structures.

Linux-style kernel code uses sophisticated versions of this idea.

---

# Part 59 — Intrusive lists

Instead of a list allocating separate nodes:

```text
node → player
```

you embed:

```c
struct Player {
    int health;

    struct ListNode node;
};
```

Then list algorithms manipulate `node`.

And:

```c
container_of(...)
```

gets back the enclosing `Player`.

This lets one generic list implementation handle arbitrary objects.

Macros help because the object/member types differ.

That's real systems-level metaprogramming.

---

# Part 60 — Macro "overloading"

C doesn't have overloaded functions by argument count.

Macros can fake it.

Suppose:

```c
#define PRINT_1(a) \
    printf("%d\n", (a))

#define PRINT_2(a, b) \
    printf("%d %d\n", (a), (b))

#define PRINT_3(a, b, c) \
    printf("%d %d %d\n", (a), (b), (c))
```

We want:

```c
PRINT(10)
PRINT(10, 20)
PRINT(10, 20, 30)
```

to select automatically.

---

# Part 61 — Count arguments

For up to eight arguments in C23:

```c
#define PP_NARG_IMPL( \
    _0, _1, _2, _3, _4, _5, _6, _7, _8, N, ...) N

#define PP_NARG(...) \
    PP_NARG_IMPL(    \
        __VA_OPT__(,) __VA_ARGS__, \
        8, 7, 6, 5, 4, 3, 2, 1, 0)
```

Examples:

```c
PP_NARG()          // 0
PP_NARG(a)         // 1
PP_NARG(a, b)      // 2
PP_NARG(a, b, c)   // 3
```

Notice how `__VA_OPT__` makes zero arguments manageable.

Before C23, empty-argument detection was one of the ugliest areas of preprocessor programming.

---

# Part 62 — Dispatch using argument count

Already have:

```c
#define CAT_RAW(a, b) a##b
#define CAT(a, b) CAT_RAW(a, b)
```

Create:

```c
#define OVERLOAD(name, ...) \
    CAT(name, PP_NARG(__VA_ARGS__))(__VA_ARGS__)
```

Then:

```c
#define PRINT1(a) \
    printf("%d\n", (a))

#define PRINT2(a, b) \
    printf("%d %d\n", (a), (b))

#define PRINT3(a, b, c) \
    printf("%d %d %d\n", (a), (b), (c))

#define PRINT(...) \
    OVERLOAD(PRINT, __VA_ARGS__)
```

Now:

```c
PRINT(10);
```

selects:

```c
PRINT1(10)
```

And:

```c
PRINT(10, 20);
```

selects:

```c
PRINT2(10, 20)
```

And:

```c
PRINT(10, 20, 30);
```

selects:

```c
PRINT3(10, 20, 30)
```

Now you're officially doing preprocessor metaprogramming.

---

# Part 63 — Fixed-size `FOR_EACH`

Suppose:

```c
#define DECLARE(x) int x;
```

You want:

```c
FOR_EACH(DECLARE, a, b, c)
```

→

```c
int a;
int b;
int c;
```

Simple production approach:

```c
#define FE_1(m, x) \
    m(x)

#define FE_2(m, x, ...) \
    m(x) FE_1(m, __VA_ARGS__)

#define FE_3(m, x, ...) \
    m(x) FE_2(m, __VA_ARGS__)

#define FE_4(m, x, ...) \
    m(x) FE_3(m, __VA_ARGS__)
```

Then dispatch using argument count.

This is boring but understandable and dependable.

---

# Part 64 — Why recursive macros are weird

You might try:

```c
#define FOREVER(x) FOREVER(x)
```

Would the preprocessor expand forever?

No.

The preprocessor suppresses a macro while that macro is actively being expanded.

That prevents straightforward infinite recursion.

This behavior is also what makes serious recursive macro techniques difficult.

---

# Part 65 — Rescanning

Suppose:

```c
#define A B
#define B C
#define C 100
```

Then:

```c
A
```

becomes:

```text
A
↓
B
↓
C
↓
100
```

After replacement, the preprocessor **rescans** results for more macros.

This rescanning rule is the heart of advanced metaprogramming.

---

# Part 66 — Why `#` and `##` behave differently

Normally arguments are expanded before substitution.

Example:

```c
#define A 100
#define ID(x) x

ID(A)
```

→

```c
100
```

But parameters directly involved with:

```text
#
##
```

don't undergo the normal prescan first.

That's why:

```c
STR_RAW
CAT_RAW
```

need an outer helper.

Once you really understand this rule, many "macro tricks" stop being magic.

---

# Part 67 — Deferred expansion

Now the crazy stuff begins.

We can deliberately postpone expansion.

A classic primitive:

```c
#define EMPTY()
```

Then:

```c
#define DEFER(id) id EMPTY()
```

Suppose:

```c
#define HELLO() hello
```

Normal:

```c
HELLO()
```

→

```c
hello
```

But:

```c
DEFER(HELLO)()
```

can make `HELLO` survive one expansion pass before another rescan triggers it.

This is used to bypass the normal self-expansion suppression rules.

---

# Part 68 — Force multiple rescans

A common pattern:

```c
#define EXPAND1(...) __VA_ARGS__

#define EXPAND2(...) \
    EXPAND1(EXPAND1(EXPAND1(EXPAND1(__VA_ARGS__))))

#define EXPAND3(...) \
    EXPAND2(EXPAND2(EXPAND2(EXPAND2(__VA_ARGS__))))

#define EXPAND4(...) \
    EXPAND3(EXPAND3(EXPAND3(EXPAND3(__VA_ARGS__))))

#define EXPAND(...) \
    EXPAND4(EXPAND4(EXPAND4(EXPAND4(__VA_ARGS__))))
```

Why?

Because sophisticated recursive macro systems need repeated rescanning until deferred expressions fully expand.

This looks insane because it kind of is.

---

# Part 69 — Recursive C23 `FOR_EACH`

Here's a real recursive macro pattern using C23's `__VA_OPT__`.

```c
#define PARENS ()

#define EXPAND1(...) __VA_ARGS__

#define EXPAND2(...) \
    EXPAND1(EXPAND1(EXPAND1(EXPAND1(__VA_ARGS__))))

#define EXPAND3(...) \
    EXPAND2(EXPAND2(EXPAND2(EXPAND2(__VA_ARGS__))))

#define EXPAND4(...) \
    EXPAND3(EXPAND3(EXPAND3(EXPAND3(__VA_ARGS__))))

#define EXPAND(...) \
    EXPAND4(EXPAND4(EXPAND4(EXPAND4(__VA_ARGS__))))
```

Then:

```c
#define FOR_EACH(macro, ...) \
    __VA_OPT__(              \
        EXPAND(FOR_EACH_HELPER(macro, __VA_ARGS__)) \
    )

#define FOR_EACH_HELPER(macro, first, ...) \
    macro(first)                             \
    __VA_OPT__(                              \
        FOR_EACH_AGAIN PARENS                \
        (macro, __VA_ARGS__)                 \
    )

#define FOR_EACH_AGAIN() FOR_EACH_HELPER
```

Now:

```c
#define DECLARE(x) int x;

FOR_EACH(DECLARE,
    alpha,
    beta,
    gamma,
    delta)
```

expands to:

```c
int alpha;
int beta;
int gamma;
int delta;
```

This is close to the point where the preprocessor starts looking like a programming language.

---

# Part 70 — Understanding that recursion

Don't memorize it yet.

Understand the idea.

You want:

```text
FOR_EACH(F, a, b, c)

↓

F(a)
FOR_EACH(F, b, c)

↓

F(a)
F(b)
FOR_EACH(F, c)

↓

F(a)
F(b)
F(c)
```

But direct recursion gets suppressed.

So advanced macro systems:

```text
1. defer the recursive call
2. let the current expansion finish
3. rescan
4. expose the recursive call
5. expand again
6. repeat
```

That's what the ugly machinery is accomplishing.

---

# Part 71 — Preprocessor Boolean programming

You can define token lookup tables.

```c
#define PP_NOT_0 1
#define PP_NOT_1 0

#define PP_NOT(x) CAT(PP_NOT_, x)
```

Then:

```c
PP_NOT(0)
```

→

```c
1
```

and:

```c
PP_NOT(1)
```

→

```c
0
```

Likewise:

```c
#define PP_AND_00 0
#define PP_AND_01 0
#define PP_AND_10 0
#define PP_AND_11 1
```

You can construct:

```c
PP_AND(1, 0)
```

by token concatenation.

Serious macro libraries build entire boolean systems this way.

Why?

Because macro metaprogramming often works by selecting tokens rather than calculating normal C values.

---

# Part 72 — Token dispatch

One of the most important advanced patterns:

```c
#define HANDLE_int(x) handle_int(x)
#define HANDLE_double(x) handle_double(x)

#define HANDLE(type, x) \
    CAT(HANDLE_, type)(x)
```

Usage:

```c
HANDLE(int, value);
```

becomes:

```c
handle_int(value);
```

Macro programming often means:

```text
convert information into tokens
↓
concatenate tokens
↓
select another macro
```

That's basically macro dispatch.

---

# Part 73 — Generate structures from schemas

Master schema:

```c
#define PLAYER_FIELDS \
    X(int, health)     \
    X(int, mana)       \
    X(float, speed)    \
    X(double, score)
```

Generate struct:

```c
#define X(type, name) type name;

struct Player {
    PLAYER_FIELDS
};

#undef X
```

Generate printing:

```c
#define PRINT_int(x) \
    printf("%d", (x))

#define PRINT_float(x) \
    printf("%f", (double)(x))

#define PRINT_double(x) \
    printf("%f", (x))
```

Then:

```c
#define X(type, name)          \
    printf(#name " = ");       \
    PRINT_##type(player->name); \
    printf("\n");

void player_print(const struct Player *player)
{
    PLAYER_FIELDS
}

#undef X
```

One schema now generates:

```text
storage
printing
serialization metadata
debugging
reflection-like tables
```

This is how macros can simulate primitive reflection in C.

---

# Part 74 — Poor man's reflection

C doesn't have built-in reflection like:

```text
give me every field in this struct
```

But if you define fields through an X-macro list:

```c
#define PERSON_FIELDS       \
    X(int, age)              \
    X(double, height)        \
    X(char *, name)
```

you can generate:

```text
struct definition
field names
field types
JSON serialization
debug printer
UI editor
binary serializer
database mappings
```

all from the same schema.

That's extremely powerful.

---

# Part 75 — Compile-time registration tables

Suppose:

```c
#define COMMANDS                    \
    X(help, command_help)            \
    X(exit, command_exit)            \
    X(status, command_status)
```

Generate:

```c
struct Command {
    const char *name;
    void (*function)(void);
};
```

Then:

```c
#define X(name, function) \
    { #name, function },

static const struct Command command_table[] = {
    COMMANDS
};

#undef X
```

You essentially built static registration without manually maintaining a table.

---

# Part 76 — Macro-generated tests

```c
#define TEST_LIST                \
    X(test_parser)               \
    X(test_network)              \
    X(test_database)
```

Declarations:

```c
#define X(name) static void name(void);

TEST_LIST

#undef X
```

Registration:

```c
#define X(name) \
    { #name, name },

static struct Test tests[] = {
    TEST_LIST
};

#undef X
```

Again: one source of truth.

---

# Part 77 — `_Static_assert` / `static_assert`

Use compile-time checks:

```c
static_assert(sizeof(void *) >= 4,
              "Pointer must be at least 32 bits");
```

Wrap checks when useful:

```c
#define REQUIRE_SIZE(type, size_) \
    static_assert(sizeof(type) == (size_), \
                  "Unexpected sizeof(" #type ")")
```

Usage:

```c
REQUIRE_SIZE(uint32_t, 4);
```

Here we're combining:

```text
sizeof
static_assert
stringification
```

---

# Part 78 — `_Pragma`

You can't easily create `#pragma` using ordinary replacement.

C provides:

```c
_Pragma("something")
```

Then build:

```c
#define DO_PRAGMA(x) _Pragma(#x)
```

Usage:

```c
DO_PRAGMA(GCC diagnostic push)
```

becomes effectively:

```c
_Pragma("GCC diagnostic push")
```

---

# Part 79 — Compiler warning wrappers

For GCC/Clang-style diagnostics:

```c
#define PRAGMA(x) _Pragma(#x)

#define DIAGNOSTIC_PUSH \
    PRAGMA(GCC diagnostic push)

#define DIAGNOSTIC_POP \
    PRAGMA(GCC diagnostic pop)
```

Then:

```c
DIAGNOSTIC_PUSH

#pragma GCC diagnostic ignored "-Wunused-parameter"

void callback(int unused)
{
}

DIAGNOSTIC_POP
```

For serious cross-platform code, you'd hide compiler differences behind macros.

---

# Part 80 — Portable attributes layer

Different compilers historically used different syntax.

You may encounter:

```c
#if defined(__GNUC__) || defined(__clang__)

#define MY_NORETURN \
    __attribute__((noreturn))

#elif defined(_MSC_VER)

#define MY_NORETURN \
    __declspec(noreturn)

#else

#define MY_NORETURN

#endif
```

Then:

```c
MY_NORETURN
void fatal_error(void);
```

This is a major macro use in portable system libraries:

> hide compiler differences behind one interface.

Modern C standards provide standard attributes for more cases, so prefer standard facilities when your target supports them.

---

# Part 81 — GCC/Clang statement expressions

Now we enter **non-portable extension territory**.

GCC and Clang GNU modes support:

```c
({
    statements;
    final_expression;
})
```

Example:

```c
int x = ({
    int a = 10;
    int b = 20;
    a + b;
});
```

`x` becomes `30`.

Not standard ISO C.

But extremely useful for macros.

---

# Part 82 — Safer GNU `MAX`

You can do:

```c
#define MAX(a, b)                       \
    ({                                  \
        __typeof__(a) max_a_ = (a);     \
        __typeof__(b) max_b_ = (b);     \
        max_a_ > max_b_ ? max_a_ : max_b_; \
    })
```

Then:

```c
MAX(i++, j++)
```

captures each expression once:

```c
max_a_ = i++;
max_b_ = j++;
```

So no duplicate evaluation.

This is why GNU C code can have much more sophisticated expression macros than strictly portable C.

---

# Part 83 — `typeof`

Historically GNU C had:

```c
__typeof__(expression)
```

Modern C23 also adds standardized `typeof`/`typeof_unqual` facilities.

So depending on your language version you may see:

```c
typeof(x)
```

or compatibility-oriented GNU code:

```c
__typeof__(x)
```

Example:

```c
typeof(value) temporary = value;
```

`temporary` gets the appropriate type.

This is incredibly useful in macro metaprogramming.

---

# Part 84 — `__auto_type`

GNU extension:

```c
__auto_type x = expression;
```

The compiler infers the type.

This can make GNU macros cleaner:

```c
#define GNU_MAX(a, b)                  \
    ({                                 \
        __auto_type max_a_ = (a);      \
        __auto_type max_b_ = (b);      \
        max_a_ > max_b_ ? max_a_ : max_b_; \
    })
```

Again:

**GNU extension**, not something to assume in portable C.

---

# Part 85 — Branch prediction macros

You may encounter:

```c
#define LIKELY(x) \
    __builtin_expect(!!(x), 1)

#define UNLIKELY(x) \
    __builtin_expect(!!(x), 0)
```

Usage:

```c
if (UNLIKELY(ptr == NULL)) {
    handle_error();
}
```

Compiler-specific.

And don't throw this everywhere because it looks cool. Use profiling before optimization hints.

---

# Part 86 — Macro-hidden control flow

You *can* make:

```c
#define RETURN_IF_NULL(ptr) \
    do {                    \
        if ((ptr) == NULL)  \
            return -1;      \
    } while (0)
```

Usage:

```c
int process(struct Data *data)
{
    RETURN_IF_NULL(data);

    ...
}
```

It works.

But it hides:

```c
return
```

inside what looks like an innocent macro call.

Use clear names if you do this.

---

# Part 87 — `goto` cleanup macros

Possible:

```c
#define CHECK_OR_GOTO(condition, label) \
    do {                                \
        if (!(condition))               \
            goto label;                 \
    } while (0)
```

Usage:

```c
FILE *file = fopen(...);

CHECK_OR_GOTO(file != NULL, cleanup);
```

Useful in some C projects.

But again: hidden control flow.

---

# Part 88 — Never casually hide `break` and `continue`

A statement macro uses:

```c
do {
    ...
} while (0)
```

Therefore:

```c
break;
```

inside that macro breaks the macro's internal `do/while`, not necessarily the surrounding loop you were thinking about.

This can create extremely confusing APIs.

Avoid macros that secretly manipulate surrounding loop control.

---

# Part 89 — Macro evaluation rules to memorize

Given:

```c
#define A 10
#define B A
```

Then:

```c
B
```

is rescanned:

```text
B
↓
A
↓
10
```

Normally macro arguments are expanded before insertion:

```c
#define ID(x) x

ID(A)
```

→ `10`

Exceptions include direct participation in:

```text
#parameter
parameter ## something
something ## parameter
```

That's why helper layers exist.

If you remember only one advanced rule:

> Macro expansion consists of argument processing, replacement, and rescanning, with special suppression rules around `#`, `##`, and currently expanding macros.

---

# Part 90 — Inspect expansions constantly

Example file:

```c
#define STR_RAW(x) #x
#define STR(x) STR_RAW(x)

#define VALUE 42

const char *a = STR_RAW(VALUE);
const char *b = STR(VALUE);
```

Run:

```bash
gcc -E -P test.c
```

You'll see something similar to:

```c
const char *a = "VALUE";
const char *b = "42";
```

Don't try to mentally debug giant macro systems forever.

Ask the preprocessor what it produced.

---

# Part 91 — Useful compiler commands

Preprocess only:

```bash
gcc -E file.c
```

Cleaner output:

```bash
gcc -E -P file.c
```

View predefined macros:

```bash
gcc -dM -E - < /dev/null
```

Compile strict C23:

```bash
gcc \
    -std=c23 \
    -Wall \
    -Wextra \
    -Wpedantic \
    file.c
```

For older GCC versions, the flag may be:

```bash
-std=c2x
```

depending on compiler version.

---

# Part 92 — `#line`

Advanced but useful for generated code.

```c
#line 500 "generated_source.c"
```

This changes the logical source position reported by things like:

```c
__LINE__
__FILE__
```

Useful in:

```text
code generators
DSLs
generated parsers
generated source files
```

so compiler errors point back to meaningful locations.

---

# Part 93 — Feature detection

Compiler code often does:

```c
#ifdef __GNUC__
```

or:

```c
#ifdef __clang__
```

But feature detection is usually better than blindly testing compiler identity.

Modern compilers may expose helpers like:

```c
__has_include(...)
__has_attribute(...)
__has_builtin(...)
```

Availability differs, so portable libraries often protect them first.

Pattern:

```c
#ifndef __has_builtin
#define __has_builtin(x) 0
#endif
```

Then:

```c
#if __has_builtin(__builtin_expect)
...
#endif
```

The exact feature-detection interface is compiler/standard-version dependent, so isolate it in one compatibility header.

---

# Part 94 — Build a compatibility layer

Good project structure:

```text
project/
    platform.h
    compiler.h
    config.h
```

`compiler.h`:

```c
#if defined(__clang__)
#define PROJECT_COMPILER_CLANG 1
#else
#define PROJECT_COMPILER_CLANG 0
#endif

#if defined(__GNUC__) && !defined(__clang__)
#define PROJECT_COMPILER_GCC 1
#else
#define PROJECT_COMPILER_GCC 0
#endif
```

Then the rest of your project says:

```c
#if PROJECT_COMPILER_GCC
```

instead of repeating ugly detection logic everywhere.

This is professional macro usage.

---

# Part 95 — Don't use macros when an enum works

Instead of:

```c
#define STATE_IDLE 0
#define STATE_RUNNING 1
#define STATE_ERROR 2
```

prefer:

```c
enum State {
    STATE_IDLE,
    STATE_RUNNING,
    STATE_ERROR
};
```

Why?

Enums belong to the C language.

Compilers understand them better.

Debuggers understand them better.

Macros should be used when preprocessing itself is needed.

---

# Part 96 — Don't use macros when a constant works

Instead of blindly:

```c
#define BUFFER_SIZE 1024
```

you can sometimes use:

```c
enum {
    BUFFER_SIZE = 1024
};
```

or an appropriately typed constant where the language rules permit it.

But configuration used in:

```c
#if BUFFER_SIZE > 100
```

must be available to the preprocessor.

That's when a macro makes sense.

---

# Part 97 — Preprocessor vs compiler: critical distinction

This:

```c
enum {
    ENABLE_FEATURE = 1
};

#if ENABLE_FEATURE
...
#endif
```

does **not** work the way beginners expect.

Why?

When `#if` runs, the compiler hasn't processed the enum yet.

The preprocessor sees:

```c
ENABLE_FEATURE
```

as an unknown preprocessing identifier and treats it as `0` in that expression.

For preprocessing configuration:

```c
#define ENABLE_FEATURE 1
```

is appropriate.

---

# Part 98 — Public macro rules

For library macros, prefer names like:

```c
MYLIB_ARRAY_LEN
MYLIB_ASSERT
MYLIB_LOG
MYLIB_VERSION_MAJOR
```

Avoid:

```c
MIN
MAX
ERROR
CHECK
DEBUG
VERSION
```

because somebody else's header may already use them.

---

# Part 99 — Don't redefine language keywords

Don't do garbage like:

```c
#define private static
#define forever for (;;)
#define begin {
#define end }
```

Yes, C's preprocessor lets people create weird pseudo-languages.

Usually don't.

Macros should make code easier to understand, not force everyone to learn your personal dialect.

---

# Part 100 — One subtle macro bug

Consider:

```c
#define ADD_ONE(x) ((x) + 1)
```

Good.

Now:

```c
#define CALL(func, args) func args
```

and:

```c
CALL(foo, (1, 2))
```

→

```c
foo(1, 2)
```

Macros can treat parenthesized token sequences as units.

Libraries exploit this to pass "tuples":

```c
#define PAIR (int, value)
```

and then use helper machinery to unpack it.

This is the beginning of tuple-oriented preprocessor programming.

---

# Part 101 — Macro tuples

Conceptually:

```c
#define FIRST_IMPL(a, b) a
#define FIRST(tuple) FIRST_IMPL tuple
```

Then:

```c
FIRST((int, value))
```

becomes:

```text
FIRST_IMPL (int, value)

↓

int
```

Similarly:

```c
#define SECOND_IMPL(a, b) b
#define SECOND(tuple) SECOND_IMPL tuple
```

Then:

```c
SECOND((int, value))
```

→

```c
value
```

This is extremely important in sophisticated macro libraries.

---

# Part 102 — Why tuple unpacking works

Given:

```c
#define FIRST(tuple) FIRST_IMPL tuple
```

Input:

```c
FIRST((int, score))
```

becomes:

```c
FIRST_IMPL (int, score)
```

And because that now looks like a function-like macro invocation:

```c
FIRST_IMPL(int, score)
```

the preprocessor expands it.

Macro metaprogramming often works by deliberately producing syntax that triggers another macro invocation during rescanning.

---

# Part 103 — Build simple data structures in the preprocessor

With techniques like:

```text
token concatenation
tuples
argument counting
deferred expansion
rescanning
boolean lookup tables
variadic macros
```

you can implement things resembling:

```text
IF
FOR_EACH
MAP
FOLD
REPEAT
WHILE
tuple access
lists
dispatch tables
arithmetic
```

Entire libraries exist that do this.

At that point, however, ask whether a code generator would be simpler.

---

# Part 104 — Preprocessor `IF`

Conceptually:

```c
#define PP_IF_0(true_case, false_case) false_case
#define PP_IF_1(true_case, false_case) true_case

#define PP_IF(condition) CAT(PP_IF_, condition)
```

Then:

```c
PP_IF(1)(yes, no)
```

with the right implementation machinery can select:

```c
yes
```

And:

```c
PP_IF(0)(yes, no)
```

selects:

```c
no
```

Notice the philosophy:

Normal programming calculates values.

Preprocessor programming frequently **selects token streams**.

---

# Part 105 — Macro arithmetic

You could theoretically create:

```c
#define INC_0 1
#define INC_1 2
#define INC_2 3
#define INC_3 4

#define INC(x) CAT(INC_, x)
```

Then:

```c
INC(2)
```

→

```c
3
```

A full macro library might define hundreds of these.

Likewise:

```text
DEC
ADD
SUB
MUL
LESS_THAN
EQUAL
```

using lookup tables and recursion.

Can you?

Yes.

Should you build a calculator with macros?

Probably not.

But understanding that it's possible teaches you how powerful token dispatch is.

---

# Part 106 — Macro-generated serialization

Example schema:

```c
#define PLAYER_FIELDS            \
    X(int, health)               \
    X(int, mana)                 \
    X(double, position_x)
```

Generate struct:

```c
#define X(type, name) type name;

struct Player {
    PLAYER_FIELDS
};

#undef X
```

Generate JSON-ish names:

```c
#define X(type, name) #name,

static const char *player_field_names[] = {
    PLAYER_FIELDS
};

#undef X
```

Generate metadata:

```c
struct FieldInfo {
    const char *name;
    size_t offset;
};
```

Then:

```c
#define X(type, name) \
    { #name, offsetof(struct Player, name) },

static const struct FieldInfo player_fields[] = {
    PLAYER_FIELDS
};

#undef X
```

You just created basic reflection metadata.

---

# Part 107 — Reflection-like metadata with types

You can extend:

```c
enum FieldType {
    FIELD_INT,
    FIELD_DOUBLE
};
```

Dispatch:

```c
#define FIELD_TYPE_int FIELD_INT
#define FIELD_TYPE_double FIELD_DOUBLE

#define FIELD_TYPE(type) \
    CAT(FIELD_TYPE_, type)
```

Then:

```c
#define X(type, name)                   \
    {                                   \
        #name,                          \
        FIELD_TYPE(type),               \
        offsetof(struct Player, name)   \
    },
```

One schema now describes:

```text
field name
field type
field offset
```

That's enough to build generic:

```text
debuggers
serializers
editors
inspectors
```

in pure C.

This is genuinely advanced.

---

# Part 108 — Macro-generated enums + `switch`

Master list:

```c
#define ERROR_LIST \
    X(NONE)         \
    X(IO)           \
    X(MEMORY)
```

Enum:

```c
#define X(name) ERROR_##name,

enum Error {
    ERROR_LIST
};

#undef X
```

String function:

```c
const char *error_name(enum Error error)
{
    switch (error) {

#define X(name) \
    case ERROR_##name: return #name;

        ERROR_LIST

#undef X

    default:
        return "UNKNOWN";
    }
}
```

One master list generates both representations.

Excellent pattern.

---

# Part 109 — Advanced logging design

```c
#define LOG_IMPL(level, ...)                       \
    do {                                           \
        fprintf(stderr,                            \
                "[%s] %s:%d %s(): ",              \
                (level),                           \
                __FILE__,                          \
                __LINE__,                          \
                __func__);                         \
        fprintf(stderr, __VA_ARGS__);              \
        fprintf(stderr, "\n");                     \
    } while (0)
```

Then:

```c
#define LOG_INFO(...) \
    LOG_IMPL("INFO", __VA_ARGS__)

#define LOG_ERROR(...) \
    LOG_IMPL("ERROR", __VA_ARGS__)
```

Usage:

```c
LOG_INFO("Starting server");

LOG_ERROR("Failed with error %d", error);
```

---

# Part 110 — Compile logging out completely

```c
#if PROJECT_LOG_LEVEL <= 1

#define LOG_DEBUG(...) \
    LOG_IMPL("DEBUG", __VA_ARGS__)

#else

#define LOG_DEBUG(...) ((void)0)

#endif
```

Compiler doesn't merely ignore it at runtime.

The preprocessor can remove the logging code entirely.

This is one reason macros are useful in low-level systems.

---

# Part 111 — Macro safety checklist

Whenever you create a function-like macro, ask:

### 1. Are arguments parenthesized?

Bad:

```c
#define DOUBLE(x) x + x
```

Better:

```c
#define DOUBLE(x) ((x) + (x))
```

### 2. Are arguments evaluated more than once?

Danger:

```c
#define SQUARE(x) ((x) * (x))
```

### 3. Is it multiple statements?

Use:

```c
do {
} while (0)
```

### 4. Can internal variables collide?

Use unusual project-specific names.

### 5. Can an inline function replace it?

If yes, strongly consider the function.

### 6. Is control flow hidden?

Be cautious with:

```text
return
goto
break
continue
```

### 7. Does it rely on compiler extensions?

Document them.

---

# Part 112 — Five macro patterns worth memorizing

## String expansion

```c
#define STR_RAW(x) #x
#define STR(x) STR_RAW(x)
```

## Token concatenation

```c
#define CAT_RAW(a, b) a##b
#define CAT(a, b) CAT_RAW(a, b)
```

## Statement macro

```c
#define DO_SOMETHING(...) \
    do {                  \
        ...               \
    } while (0)
```

## Disabled statement

```c
#define FEATURE(...) ((void)0)
```

## X-macro master list

```c
#define ITEMS \
    X(A)       \
    X(B)       \
    X(C)
```

If these five feel natural, you've already passed beginner macro programming.

---

# Part 113 — Five advanced ideas worth mastering

Next master:

```text
1. variadic macros
2. __VA_OPT__
3. _Generic
4. argument-count dispatch
5. X-macro code generation
```

Those solve most realistic advanced macro problems.

---

# Part 114 — Five insane ideas to understand, not necessarily use

Finally:

```text
1. deferred expansion
2. recursive FOR_EACH
3. tuple unpacking
4. token Boolean logic
5. recursive preprocessor metaprogramming
```

Knowing these means very little macro code will scare you.

But production code should generally use the simplest technique that works.

---

# Part 115 — The three levels of macro programmers

### Level 1 — beginner

Can use:

```c
#define SIZE 100
#define SQUARE(x) ((x) * (x))
#ifdef DEBUG
```

### Level 2 — strong C programmer

Understands:

```text
side effects
do/while(0)
#
##
variadics
__VA_OPT__
rescan
argument expansion
_Generic
X-macros
compiler configuration
```

### Level 3 — macro wizard

Understands:

```text
recursive expansion
deferral
forced rescans
tuple manipulation
token dispatch
argument-count overloading
FOR_EACH
macro schemas
reflection-like generation
compiler extensions
```

Your target should be **Level 2.5**.

You should understand Level 3 code, but you shouldn't make every program Level 3.

---

# Part 116 — The most important principle

A beginner sees:

```c
#define
```

and thinks:

> convenient shortcut.

An intermediate programmer thinks:

> dangerous textual substitution.

An advanced programmer thinks:

> compile-time token transformation system.

That's the correct final mental model.

Macros aren't miniature functions.

They're a mechanism for transforming the source program before the compiler sees it.

---

# Final cheat sheet

Keep this nearby:

```c
/* Object macro */
#define SIZE 1024


/* Function macro */
#define ADD(a, b) ((a) + (b))


/* Stringification */
#define STR_RAW(x) #x
#define STR(x) STR_RAW(x)


/* Token concatenation */
#define CAT_RAW(a, b) a##b
#define CAT(a, b) CAT_RAW(a, b)


/* Statement macro */
#define ACTION(x)       \
    do {                \
        process((x));   \
    } while (0)


/* Variadic */
#define PRINT(...) \
    printf(__VA_ARGS__)


/* C23 optional variadic content */
#define LOG(format, ...) \
    fprintf(stderr, format __VA_OPT__(,) __VA_ARGS__)


/* Conditional compilation */
#if defined(DEBUG)
...
#endif


/* Compile-time failure */
#error Something is wrong


/* Generic selection */
#define TYPE_NAME(x) _Generic((x), \
    int: "int",                     \
    double: "double",               \
    default: "unknown")


/* Unique-ish identifier */
#define UNIQUE(name) \
    CAT(name, __LINE__)


/* Array length */
#define ARRAY_LEN(x) \
    (sizeof(x) / sizeof((x)[0]))


/* container_of */
#define CONTAINER_OF(ptr, type, member) \
    ((type *)((char *)(ptr) - offsetof(type, member)))


/* X-macro */
#define ITEMS \
    X(ONE)     \
    X(TWO)     \
    X(THREE)
```

## The order I want you to learn this in

Don't try to memorize all 116 sections at once. Go through them in these **8 checkpoints**:

1. **Basics:** `#define`, arguments, parentheses, side effects.
2. **Safe macros:** `do { } while (0)`, hygiene, namespaces.
3. **Expansion:** `#`, `##`, two-level expansion, rescanning.
4. **Configuration:** `#if`, `defined`, `#error`, compiler flags.
5. **Variadics:** `__VA_ARGS__`, `__VA_OPT__`.
6. **Real metaprogramming:** `_Generic`, X-macros, schemas, generated tables.
7. **Advanced dispatch:** argument counting, overloading, `FOR_EACH`.
8. **Wizard level:** deferred expansion, recursion, tuples, GNU extensions.

And whenever something looks magical, run:

```bash
gcc -E -P program.c
```

That one habit will probably teach you macros faster than reading hundreds of pages of manuals.
