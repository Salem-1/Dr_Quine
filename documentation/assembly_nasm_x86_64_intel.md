# NASM x86-64 Macros — From Basics to Advanced Use

This crash course focuses on one question:

> **How do NASM macros actually work, from the simplest substitution all the way to generating entire programs?**

We will build everything from one mental model.

---

# Part 1 — The Mental Model

Suppose we define:

```asm
%macro ZERO 1
    xor %1, %1
%endmacro
```

and later write:

```asm
ZERO eax
```

NASM does **not** put a macro called `ZERO` into the executable.

Before assembly, the preprocessor expands:

```asm
ZERO eax
```

into:

```asm
xor eax, eax
```

Then NASM assembles that ordinary instruction.

The process is:

```text
source.asm
    ↓
NASM preprocessor
    ↓
macros expand into assembly source
    ↓
NASM assembler
    ↓
machine code
    ↓
CPU executes machine code
```

So this:

```asm
MY_MACRO rax, rbx
```

should mentally mean:

```text
"NASM, generate some assembly here using rax and rbx."
```

It does **not** mean:

```text
"CPU, call a macro."
```

Macros therefore have:

* no runtime call
* no automatic `ret`
* no automatic stack frame
* no automatic registers
* no runtime macro overhead
* no automatic type checking
* no automatic ABI awareness

They generate source code.

This leads to an important consequence:

> A macro can generate almost any part of the program—including the program's entry point.

---

# Part 2 — Can the Program Start Inside a Macro?

Yes.

In fact, this is one of the best examples for understanding what a macro really is.

Consider a Linux program using `_start`.

Normally we could write:

```asm
bits 64

section .text
global _start

_start:
    mov eax, 60
    xor edi, edi
    syscall
```

Now put the entry point inside a macro:

```asm
bits 64

%macro PROGRAM_START 0

section .text
global _start

_start:
    mov eax, 60
    xor edi, edi
    syscall

%endmacro


PROGRAM_START
```

At first glance, it can look as though:

```asm
PROGRAM_START
```

is somehow executed by the program.

It is not.

NASM sees:

```asm
PROGRAM_START
```

during preprocessing.

The macro expands into:

```asm
section .text
global _start

_start:
    mov eax, 60
    xor edi, edi
    syscall
```

So after preprocessing, the assembler effectively sees an ordinary program containing:

```asm
_start:
```

The linker then records `_start` as the executable entry point.

When the program runs, execution begins at the machine code corresponding to:

```asm
_start:
```

The macro itself no longer exists.

---

## The Important Distinction

It is tempting to say:

> "The program runs from the macro."

That is understandable, but technically the better mental model is:

> **The macro generates the program's entry point.**

The sequence is:

```text
PROGRAM_START
      ↓
NASM preprocessor
      ↓
generates _start:
      ↓
assembler creates machine code
      ↓
linker makes _start the entry point
      ↓
OS starts executing generated machine code
```

So macros can generate code that runs first, but **macro expansion itself happens before the program exists**.

---

# Part 3 — A Macro Can Generate Much More Than Instructions

This is why thinking of macros merely as instruction shortcuts is too limited.

A macro can generate:

```text
instructions
labels
entry points
functions
sections
data
constants
tables
global symbols
loops
entire families of functions
```

For example:

```asm
%macro DEFINE_PROGRAM 0

section .data
    value dq 123

section .text
global _start

_start:
    mov rax, [value]

    mov eax, 60
    xor edi, edi
    syscall

%endmacro


DEFINE_PROGRAM
```

Here a single macro invocation generates nearly the whole source program.

Conceptually:

```text
DEFINE_PROGRAM
```

expands into:

```asm
section .data
    value dq 123

section .text
global _start

_start:
    mov rax, [value]

    mov eax, 60
    xor edi, edi
    syscall
```

NASM does not care that those lines came from a macro.

After preprocessing, they are simply assembly source.

This gives us the most important rule for the rest of the course:

> **Anywhere ordinary NASM source can appear, macros can often be used to generate that source.**

We will start small and gradually work toward generating larger structures like this.

---

# Part 4 — Before `%macro`: Three Ways NASM Can Define Things

Before writing larger macros, distinguish three mechanisms that look similar but serve different purposes.

## 4.1 `equ` — assembler constant

```asm
BUFFER_SIZE equ 4096
```

Usage:

```asm
sub rsp, BUFFER_SIZE
```

`equ` defines an assembler-time symbolic constant.

Another common example:

```asm
message db "hello"
message_len equ $ - message
```

Here:

```asm
$
```

means the current assembly position.

Therefore:

```asm
$ - message
```

calculates the size of `message`.

Use `equ` when you simply need a constant.

---

## 4.2 `%define` — preprocessor substitution

```asm
%define SIZE 100
```

Then:

```asm
mov eax, SIZE
```

is preprocessed approximately into:

```asm
mov eax, 100
```

You can substitute other tokens too:

```asm
%define ARG1 rdi
```

Then:

```asm
mov rax, ARG1
```

becomes:

```asm
mov rax, rdi
```

The important idea is:

```text
%define → substitute tokens before assembly
```

---

## 4.3 Function-Like `%define`

A `%define` can take parameters:

```asm
%define BIT(n) (1 << (n))
```

Then:

```asm
READ_FLAG  equ BIT(0)
WRITE_FLAG equ BIT(1)
EXEC_FLAG  equ BIT(2)
```

becomes conceptually:

```asm
READ_FLAG  equ 1
WRITE_FLAG equ 2
EXEC_FLAG  equ 4
```

Another example:

```asm
%define KiB(x) ((x) * 1024)
```

Then:

```asm
BUFFER_SIZE equ KiB(64)
```

produces the constant:

```text
65536
```

Use function-like `%define` for small expressions and substitutions.

When we want to generate multiple assembly lines, we move to `%macro`.

---

# Part 5 — Your First Multiline Macro

Now that we know a macro could theoretically generate an entire `_start`, let's reduce the idea to its smallest form.

The syntax is:

```asm
%macro NAME argument_count

    ; generated source

%endmacro
```

Example:

```asm
%macro CLEAR_RAX 0
    xor eax, eax
%endmacro
```

Usage:

```asm
CLEAR_RAX
```

Expansion:

```asm
xor eax, eax
```

The `0` means:

```text
this macro takes zero arguments
```

This tiny macro and the earlier `PROGRAM_START` macro work by exactly the same mechanism.

The only difference is how much source they generate:

```text
CLEAR_RAX
    ↓
one instruction
```

versus:

```text
PROGRAM_START
    ↓
sections + symbols + label + instructions
```

That is why it is useful to learn macros as **source generators from the beginning**, rather than thinking of them only as shortcuts.

---

From here, continue into:

1. macro parameters `%1`, `%2`, ...
2. argument count `%0`
3. operand aliasing
4. `%%` macro-local labels
5. runtime loops generated by macros
6. clobbers and side effects
7. variadic macros
8. `%rep`, `%rotate`, `%assign`
9. compile-time generation
10. conditions and validation
11. generated names
12. automatic IDs
13. one-source-of-truth metaprogramming
14. advanced features and edge cases

Absolutely. The best way to check that you understood these is to see **what you write versus what NASM effectively generates**. The concepts below follow the progression in your original crash course, including `%0`, `%%` labels, `%rep`, `%rotate`, generated symbols, and automatic IDs. 

---

# 1. Macro parameters — `%1`, `%2`, `%3`, ...

### Meaning

Parameters are the arguments you give to a macro.

If the macro takes two arguments:

```asm
%macro MOVE 2
    mov %1, %2
%endmacro
```

then:

```text
%1 = first argument
%2 = second argument
```

### العربية الفصحى

**معاملات الماكرو**: هي القيم أو الرموز التي تمرّرها إلى الماكرو، ويشير `%1` إلى المعامل الأول، و`%2` إلى الثاني، وهكذا.

### المصري

**باراميترات الماكرو**: الحاجات اللي إنت بتديهاله لما تستخدمه.
`%1` يعني أول حاجة، و`%2` يعني تاني حاجة، وهكذا.

### Example

```asm
%macro MOVE 2
    mov %1, %2
%endmacro

MOVE rax, rbx
```

NASM effectively generates:

```asm
mov rax, rbx
```

Because:

```text
%1 = rax
%2 = rbx
```

Another call:

```asm
MOVE rcx, 100
```

becomes:

```asm
mov rcx, 100
```

### Mental model

When you see:

```asm
MOVE rax, rbx
```

mentally substitute:

```text
%1 → rax
%2 → rbx
```

---

# 2. Argument count — `%0`

`%0` tells you **how many arguments were passed to the current macro invocation**. This is exactly how your original guide introduces it. 

### العربية الفصحى

**عدد معاملات الماكرو**: يحتوي `%0` على عدد المعاملات التي مُرِّرت إلى الماكرو.

### المصري

`%0` بيقولك **إنت بعتّ للماكرو كام argument**.

### Example

```asm
%macro TEST 1-3
    %warning Number of arguments = %0
%endmacro
```

Calls:

```asm
TEST rax
TEST rax, rbx
TEST rax, rbx, rcx
```

Inside each invocation:

```text
TEST rax
%0 = 1

TEST rax, rbx
%0 = 2

TEST rax, rbx, rcx
%0 = 3
```

This becomes especially useful later with:

```asm
%rep %0
```

meaning:

> repeat once for every macro argument.

---

# 3. Operand aliasing

This one is extremely important.

### العربية الفصحى

**تَشارُك المعاملات في السجل نفسه**: يحدث عندما يشير معاملان مختلفان في الماكرو إلى السجل نفسه، مما قد يؤدي إلى تعديل قيمة قبل أن ينتهي الماكرو من استخدامها.

### المصري

دي بتحصل لما اتنين arguments مختلفين في الماكرو يطلعوا **نفس الريجيستر**، فالماكرو يغيّر القيمة بدري قبل ما يخلص استخدامها.

### Example

```asm
%macro ADD3 3
    mov %1, %2
    add %1, %3
%endmacro
```

Normal use:

```asm
ADD3 rax, rbx, rcx
```

becomes:

```asm
mov rax, rbx
add rax, rcx
```

Fine.

But:

```asm
ADD3 rax, rbx, rax
```

means:

```text
%1 = rax
%2 = rbx
%3 = rax
```

Expansion:

```asm
mov rax, rbx
add rax, rax
```

Problem.

You perhaps intended:

```text
old rbx + old rax
```

but after:

```asm
mov rax, rbx
```

the **old value of `rax` is gone**.

### Mental question

Whenever you write a macro with several register parameters, ask:

> ماذا يحدث إذا كان `%1` و`%3` هما السجل نفسه؟

Egyptian:

> طب لو `%1` و`%3` طلعوا نفس الريجيستر، الدنيا هتبوظ؟

---

# 4. Macro-local labels — `%%`

Suppose your macro needs a jump.

Bad:

```asm
%macro ABS64 1

    test %1, %1
    jns done

    neg %1

done:

%endmacro
```

If you call it twice:

```asm
ABS64 rax
ABS64 rbx
```

you would generate `done:` twice.

Instead:

```asm
%macro ABS64 1

    test %1, %1
    jns %%done

    neg %1

%%done:

%endmacro
```

Every macro invocation gets its own private label. This is the purpose of `%%label` in your original guide. 

### العربية الفصحى

**تسمية محلية خاصة بالماكرو**: الاسم الذي يبدأ بـ`%%` يحصل على نسخة فريدة لكل استدعاء للماكرو.

### المصري

`%%label` يعني:

> الليبل ده جوه الماكرو بس، وكل مرة تستخدم الماكرو NASM يعمل له اسم مختلف لوحده.

### Conceptually

```asm
ABS64 rax
ABS64 rbx
```

might internally become something conceptually like:

```asm
test rax, rax
jns unique_label_1
neg rax
unique_label_1:

test rbx, rbx
jns unique_label_2
neg rbx
unique_label_2:
```

The exact generated internal names don't matter.

What matters is:

```text
%%done
```

doesn't collide between invocations.

---

# 5. Runtime loops generated by macros

This one has **two different times** involved.

### العربية الفصحى

**حلقة تشغيل يولّدها الماكرو**: يعمل الماكرو أثناء المعالجة المسبقة، لكنه يولّد تعليمات قفز وتكرار تُنفَّذ لاحقًا أثناء تشغيل البرنامج.

### المصري

الماكرو نفسه بيشتغل قبل البرنامج، بس ممكن **يولّد كود فيه loop**، والـloop دي هي اللي تشتغل وقت تشغيل البرنامج.

### Example

```asm
%macro ZERO_ARRAY 2

%%loop:
    test %2, %2
    jz %%done

    mov qword [%1], 0
    add %1, 8
    dec %2

    jmp %%loop

%%done:

%endmacro
```

Call:

```asm
ZERO_ARRAY rdi, rcx
```

NASM generates approximately:

```asm
.loop:
    test rcx, rcx
    jz .done

    mov qword [rdi], 0
    add rdi, 8
    dec rcx

    jmp .loop

.done:
```

The distinction:

```text
ZERO_ARRAY expansion
        ↓
assembly time

generated loop
        ↓
runtime
```

So the macro does **not loop at runtime**.

It generates a loop that runs at runtime.

---

# 6. Clobbers and side effects

Consider that previous macro:

```asm
ZERO_ARRAY rdi, rcx
```

It changes:

```text
RDI
RCX
RFLAGS
memory
```

### العربية الفصحى

**Clobbers**: السجلات أو الأعلام التي يغيّرها الكود المولَّد ولا يحافظ على قيمها الأصلية.

**Side effects**: التأثيرات الجانبية مثل تعديل الذاكرة أو المكدس أو الأعلام.

### المصري

**Clobber** يعني:

> الريجيستر أو الفلاج اللي الماكرو هيغيّر قيمته ومش هيرجّعهالك زي ما كان.

**Side effect** يعني:

> حاجة تانية حصلت بسبب الكود، زي إنه غيّر memory أو `rsp` أو flags.

### Example

```asm
%macro INCREMENT 1
    inc qword [%1]
%endmacro
```

Call:

```asm
INCREMENT rdi
```

Expansion:

```asm
inc qword [rdi]
```

Effects:

```text
RDI?       preserved
memory?    modified
RFLAGS?    modified
RSP?       preserved
```

Good macro documentation:

```asm
; INCREMENT ptr
;
; Input:
;   ptr = address of qword
;
; Modifies:
;   qword [ptr]
;
; Clobbers:
;   RFLAGS
```

---

# 7. Variadic macros

Variadic means:

> a macro can accept a variable number of arguments.

### العربية الفصحى

**ماكرو متغيّر العدد من المعاملات**: ماكرو يستطيع استقبال عدد غير ثابت من المعاملات.

### المصري

ماكرو تقدر تبعتله **عدد arguments على مزاجك**، مش لازم عدد ثابت.

For example:

```asm
PUSH_REGS rax
```

or:

```asm
PUSH_REGS rax, rbx
```

or:

```asm
PUSH_REGS rax, rbx, rcx, rdx
```

Definition:

```asm
%macro PUSH_REGS 1-*

    %rep %0
        push %1
        %rotate 1
    %endrep

%endmacro
```

Here:

```text
1-* = minimum 1 argument, no fixed maximum
```

Call:

```asm
PUSH_REGS rax, rbx, rcx
```

produces:

```asm
push rax
push rbx
push rcx
```

---

# 8. `%rep`, `%rotate`, `%assign`

These three work together often, but they do different jobs.

## `%rep`

### العربية الفصحى

**تكرار أثناء التجميع/المعالجة المسبقة**.

### المصري

كرّرلي الكود ده **قبل ما البرنامج يشتغل**.

Example:

```asm
%rep 3
    nop
%endrep
```

generates:

```asm
nop
nop
nop
```

There is no runtime loop. Your guide emphasizes exactly this difference. 

---

## `%rotate`

Rotates macro arguments.

### العربية الفصحى

**تدوير معاملات الماكرو** بحيث يصبح المعامل التالي هو `%1`.

### المصري

بيزقّ الـarguments لفة، بحيث اللي كان `%2` يبقى `%1`.

Start:

```text
%1 = rax
%2 = rbx
%3 = rcx
```

After:

```asm
%rotate 1
```

conceptually:

```text
%1 = rbx
%2 = rcx
%3 = rax
```

That's why this works:

```asm
%rep %0
    push %1
    %rotate 1
%endrep
```

Your original guide uses this exact mechanism for variadic argument iteration. 

---

## `%assign`

Creates a mutable compile-time integer.

### العربية الفصحى

**متغيّر عددي وقت المعالجة المسبقة** يمكن تغيير قيمته أثناء توليد الكود.

### المصري

متغيّر رقم NASM نفسه بيستخدمه وهو بيولّد الكود، مش variable موجود وقت تشغيل البرنامج.

Example:

```asm
%assign i 0

%assign i i + 1
%assign i i + 1
```

Now:

```text
i = 2
```

But there is no runtime variable named `i`.

---

# 9. Compile-time generation

This is the big concept behind `%rep` + `%assign`.

### العربية الفصحى

**توليد الكود وقت التجميع**: يقوم NASM بحساب أو إنشاء التعليمات والبيانات قبل تشغيل البرنامج.

### المصري

NASM بيحسب ويكوّن الكود **وهو بيبني البرنامج**، بدل ما الـCPU يعمل الحساب ده وقت التشغيل.

### Example

```asm
square_table:

%assign i 0

%rep 4

    dq i * i

    %assign i i + 1

%endrep
```

NASM generates:

```asm
square_table:
    dq 0
    dq 1
    dq 4
    dq 9
```

The CPU doesn't calculate:

```text
0 × 0
1 × 1
2 × 2
3 × 3
```

NASM did it beforehand.

Think:

```text
source generator
     ↓
creates data/instructions
     ↓
CPU gets final result
```

---

# 10. Conditions and validation

Macros can make decisions **while assembling**.

### العربية الفصحى

**الشروط والتحقق**: يستطيع المعالج المسبق اختبار شروط معينة ورفض الاستخدام غير الصحيح قبل إنشاء البرنامج.

### المصري

تقدر تخلي NASM يقول:

> لأ، الاستخدام ده غلط، ومش هكمّل build أصلًا.

### Example

We want stack allocation to be divisible by 16:

```asm
%macro ALLOC_LOCAL 1

    %if (%1) % 16
        %error "Size must be divisible by 16"
    %endif

    sub rsp, %1

%endmacro
```

This:

```asm
ALLOC_LOCAL 32
```

works.

NASM generates:

```asm
sub rsp, 32
```

But:

```asm
ALLOC_LOCAL 24
```

causes an assembly-time error.

### Important distinction

This validation happens **before runtime**.

It's not equivalent to:

```asm
cmp ...
jne error
```

There is no runtime check.

The bad program simply isn't assembled.

---

# 11. Generated names

Macros can generate symbols themselves.

### العربية الفصحى

**توليد أسماء الرموز**: إنشاء أسماء labels أو functions أو constants تلقائيًا أثناء المعالجة المسبقة.

### المصري

الماكرو يركّب الاسم بنفسه بدل ما تكتبه يدوي كل مرة.

For example, conceptually:

```text
player + _data
```

can become:

```text
player_data
```

NASM uses token concatenation such as:

```text
%+
```

Example idea:

```asm
%define CAT(a,b) a %+ b

CAT(player, _data)
```

produces the symbol:

```asm
player_data
```

Now imagine generating functions:

```text
get_health
get_mana
get_score
```

from only:

```text
health
mana
score
```

That's generated naming.

Your original guide introduces `%+` specifically for creating symbols automatically. 

---

# 12. Automatic IDs

Now combine:

```text
%assign
+
generated names
```

### العربية الفصحى

**المعرّفات التلقائية**: توليد أرقام متسلسلة للرموز تلقائيًا بدل تعيين كل رقم يدويًا.

### المصري

بدل ما تكتب:

```text
RED = 0
GREEN = 1
BLUE = 2
```

تخلي NASM يعدّ لوحده.

### Example

```asm
%assign COLOR_ID 0

%macro COLOR 1

    COLOR_%1 equ COLOR_ID
    %assign COLOR_ID COLOR_ID + 1

%endmacro


COLOR RED
COLOR GREEN
COLOR BLUE

COLOR_COUNT equ COLOR_ID
```

Conceptually produces:

```text
COLOR_RED   = 0
COLOR_GREEN = 1
COLOR_BLUE  = 2
COLOR_COUNT = 3
```

Now add:

```asm
COLOR YELLOW
```

and you automatically get:

```text
COLOR_YELLOW = 3
COLOR_COUNT  = 4
```

No manual renumbering.

That's the benefit.

---

# 13. One-source-of-truth metaprogramming

This is probably the **most important advanced idea**.

Imagine your CPU emulator has operations:

```text
ADD
SUB
MUL
DIV
```

You need:

```text
numeric IDs
function pointers
names for debugging
extern declarations
```

Bad design means maintaining four separate lists.

For example:

```asm
OP_ADD equ 0
OP_SUB equ 1
OP_MUL equ 2
OP_DIV equ 3
```

plus:

```asm
dispatch_table:
    dq op_add
    dq op_sub
    dq op_mul
    dq op_div
```

plus perhaps:

```text
"ADD"
"SUB"
"MUL"
"DIV"
```

Now imagine adding:

```text
MOD
```

You have to remember to modify everything.

---

### Better idea

Maintain only:

```text
ADD    op_add
SUB    op_sub
MUL    op_mul
DIV    op_div
```

and let macros derive everything else.

### العربية الفصحى

**مصدر واحد للحقيقة**: الاحتفاظ بتعريف المعلومة في مكان واحد، ثم توليد جميع الجداول والثوابت والأسماء الأخرى منه تلقائيًا.

### المصري

تكتب المعلومة **مرة واحدة بس**، وكل الحاجات التانية تتولّد منها.

بدل ما يبقى عندك 4 قوائم وممكن تنسى تحدّث واحدة.

This is the difference between:

> macros as shortcuts

and:

> macros as metaprogramming.

---

# 14. Advanced features and edge cases

Once everything above feels natural, these are the things to explore.

### العربية الفصحى

**الميزات المتقدمة والحالات الحدّية**: أدوات إضافية ومواقف خاصة تظهر عندما تصبح أنظمة الماكرو أكثر تعقيدًا.

### المصري

الحاجات اللي بتظهر لما الماكروز تكبر وتبقى فيها شغل أذكى أو حالات غريبة لازم تاخد بالك منها.

A few examples:

### A. Default parameters

```asm
%macro ZERO 0-1 rax
    xor %1, %1
%endmacro
```

So:

```asm
ZERO
```

uses `rax`.

While:

```asm
ZERO rdx
```

uses `rdx`.

---

### B. Macro overloading

You can have:

```asm
%macro LOAD 2
    mov %1, %2
%endmacro
```

and:

```asm
%macro LOAD 3
    mov %1, [%2 + %3]
%endmacro
```

So:

```asm
LOAD rax, rbx
```

and:

```asm
LOAD rax, rbx, 16
```

mean different things.

---

### C. Reject particular registers

Suppose your macro cannot safely accept `rsp`.

```asm
%macro SOMETHING 1

    %ifidni %1, rsp
        %error "RSP cannot be used here"
    %endif

    ; ...

%endmacro
```

Now:

```asm
SOMETHING rax
```

works.

But:

```asm
SOMETHING rsp
```

fails while assembling.

---

### D. Stack-alignment edge cases

Consider:

```asm
%macro SAVE 2
    push %1
    push %2
%endmacro
```

It looks harmless.

But:

```asm
SAVE rbx, r12
```

generates:

```asm
push rbx
push r12
```

and therefore changes:

```text
RSP -= 16
```

A different number of pushes can change stack alignment before a function call.

So macros can hide ABI problems.

---

### E. Flags edge cases

This:

```asm
cmp rax, rbx

ZERO rcx

je equal
```

looks innocent.

But if:

```asm
ZERO rcx
```

expands to:

```asm
xor rcx, rcx
```

then `xor` changes flags.

So:

```asm
je equal
```

is no longer using the flags from `cmp`.

It's using the flags from `xor`.

This is why the later parts of your original guide emphasize registers, flags, stack changes, memory side effects, and ABI assumptions when designing macros. 

---

# The whole progression in one picture

Try to see the concepts as one chain rather than 14 unrelated features:

```text
%1, %2
│
├── Give macros inputs
│
%0
│
├── Know how many inputs exist
│
variadic macros
│
├── Accept arbitrary numbers of inputs
│
%rotate
│
├── Walk through those inputs
│
%rep
│
├── Generate something repeatedly
│
%assign
│
├── Keep compile-time state
│
generated names
│
├── Generate symbols
│
automatic IDs
│
├── Generate related constants
│
conditions / validation
│
├── Control and verify generation
│
one source of truth
│
└── Generate whole related systems
```

And throughout **all of it**, keep asking:

```text
What exact assembly will this expand into?
```

بالفصحى:

> **ما تعليمات التجميع الفعلية التي سيولّدها هذا الماكرو؟**

بالمصري:

> **الماكرو ده في الآخر هيفردهولي لإيه بالظبط؟**

If that question becomes automatic in your head, you've understood the core of NASM macros.
****