# Inline RBS comments

Spinel reads RBS type annotations written as comments in the Ruby source,
in the syntax [ruby/rbs](https://github.com/ruby/rbs) and
[Sorbet](https://sorbet.org/docs/rbs-support) document:

```ruby
class Bag
  EMPTY = [].freeze

  attr_reader :count #: Integer

  # @rbs @items: Array[Integer]?

  #: (Array[Integer]) -> void
  def initialize(items)
    @items = items
    @count = items.size
  end

  #: -> Array[Integer]
  def items = @items || EMPTY
end
```

An annotation means exactly what the same signature in a `.rbs` file means
to [`--rbs`](rbs-extract.md): it pins the slot, and the program compiles to
the same C it would with that `.rbs` file. Annotations are comments, so
CRuby ignores them and the program's behaviour under CRuby does not change.
They are read on every compile; `--no-inline-rbs` turns them off.

## What an annotation does

An applied annotation is a seed, with the whole of a seed's trust model:

1. **It is an assertion.** The slot is pinned to the declared type, and a
   value the compiler can see that contradicts it is a compile error,
   reported at the store (see [Contradictions](rbs-extract.md#contradictions)).
2. **A seeded parameter converts its argument** on a dynamic call, and
   raises `TypeError` where it cannot.
3. **Built with `-DSP_RBS_CHECK`**, every place a boxed value narrows into a
   pinned slot checks its tag and aborts on a mismatch
   (see [Checking seeds](rbs-extract.md#checking-seeds)).

A false annotation the compiler cannot see is not caught otherwise: the
value is reinterpreted, as with a false `.rbs` signature. Write annotations
that describe the program.

A contradiction is reported as the annotation's, naming both the code that
contradicts it and the annotation:

```
spinel: meter.rb:9: inline RBS annotation contradicted: @reading is declared Integer at meter.rb:6 but this assigns String
```

Two messages of the compiled program itself -- the `SP_RBS_CHECK` abort
(`--rbs seed violated`) and the `TypeError` of a `send` that picks a method
whose seeded parameter the arguments contradict -- name the slot in
`--rbs`'s words whichever source pinned it: the program does not carry
where a pin came from.

Leaving a declaration unannotated leaves it to inference. Spinel does not
adopt the references' default that an unannotated method is
`(?) -> untyped` or inherits its super method's type, or that an
unannotated attribute is `untyped`: those would box slots that inference
types precisely today.

## Supported forms

| Form | Example | Source |
|---|---|---|
| Method type above a `def` | `#: (Integer, String) -> bool` | both |
| No parameters | `#: -> void` | Sorbet |
| `@rbs` method type | `# @rbs (Integer) -> Integer` | ruby/rbs |
| Continued with `#\|` | `#: (Integer,` then `#\|  String) -> void` | Sorbet |
| Continued by indentation | `# @rbs (Integer,` then `#   String) -> void` | ruby/rbs |
| Parameter and return lines | `# @rbs x: Integer`, `# @rbs k: Symbol`, `# @rbs return: String` | ruby/rbs |
| Return after the parameters | `def m(x) #: Integer` | ruby/rbs |
| Endless `def` | `def m(x) = x #: Integer` | ruby/rbs `master` |
| Class methods | above `def self.m`, or a `def` in `class << self` | both |
| Modifiers | above `private def m(x)` | both |
| Skip a method | `# @rbs skip` | ruby/rbs |
| Attribute, trailing | `attr_reader :name, :title #: String` | ruby/rbs |
| Attribute, leading | `#: String` on the line above `attr_accessor :name` | Sorbet |
| Instance variable | `# @rbs @name: String` in a class body | ruby/rbs |
| Instance variable write | `@name = nil #: String?` in an instance method | Sorbet |

The types are the ones `--rbs` can pin: `Integer`, `Float`, `String`,
`Symbol`, `bool`, `nil`/`void`, `untyped`, classes of the program,
`Array[T]`, `Hash[K, V]`, `T?`, unions (as boxed values) and
`singleton(C)`. See [Type vocabulary](rbs-extract.md#type-vocabulary).

A method's annotation is one signature: a method type (`#:` or
`# @rbs (...) -> ...`), or parameter and return lines. The parameters of a
method type are matched to the `def`'s by position and keyword name. Only
required positional and keyword parameters can be seeded; a block parameter
after them is left to inference.

`@x = v #: T` declares the instance variable, as `@x: T` in a `.rbs` does;
it is not a check of that one write.

## Where an annotation attaches

- A comment block above a `def` or an `attr_*` call attaches to it. Blank
  lines and ordinary comments may come between them; a statement may not
  (Sorbet's rule; ruby/rbs alone would also detach at a blank line).
- A trailing `#:` attaches to the `def` whose parameter list ends on that
  line, or to the attribute or instance variable write ending there.
- `# @rbs @x: T` belongs to the class body it is written in, whichever
  declaration follows it.
- Inside `Name = Struct.new(...) do ... end`, `Class.new do` and
  `Data.define do`, annotations belong to `Name`, as a `.rbs` file would
  declare it.
- Only the program's own files are read: the entry file and what it
  `require`s and `require_relative`s, as the compiler parses them. A Ruby
  file under an `--rbs` directory is never read.

## What is not applied, and what Spinel says

Every comment that starts like an annotation is applied, refused, or
ignored with a warning. Nothing is applied in part.

| Situation | Response |
|---|---|
| An annotation that does not parse | **error** at its line and column, with the RBS parser's message |
| Two signatures for one method, or one parameter annotated twice | **error** naming both lines |
| An annotation disagreeing with an `--rbs` signature, or with another annotation of the same method | **error** naming both |
| A type Spinel cannot pin: literal types, interfaces, tuples, records, procs, `self`/`instance`/`class`, type variables | **warning**; the whole annotation is ignored |
| A type naming a class the program does not define (`Time`, `Array[Time]`, `Net::HTTP`) | **warning** naming the type as written; the whole annotation is ignored |
| Optional, rest, trailing, rest-keyword and block parameters (`?T`, `*T`, `# @rbs *a:`, `&block:`) | **warning**; ignored |
| Overloads (several `#:` lines, or `\|` in `# @rbs`) and `...` | **warning**; ignored (`--rbs` keeps the first overload; an annotation is never applied in part) |
| Generic methods `#: [U] (U) -> U` | **warning**; ignored |
| Local variables `x = v #: T`, casts `#: as T`, `#: as !nil`, `#: as untyped`, `#: absurd`, `#: self as T` | **warning**; ignored: Spinel does not hold a type for one expression |
| Constants `X = 1 #: Integer`, `#: class-alias`, `#: [E]` on a class, `#[T]` on a superclass or mixin, `#: type t = ...` | **warning**; ignored |
| An instance variable written in a class body or class method, or declared in `class << self` | **warning**; ignored: a class's own variables are not seeded |
| An annotation that attaches to nothing (a statement follows it, the file ends, it is inside a method body) | **warning** with the reason |
| An annotated method or attribute the analyzer finds no class for | **warning**; ignored |
| The return type of a method a related class overrides | **warning**; the return stays inferred and the parameters are applied, as with `--rbs` |
| An annotated method of a module mixed in with `include`, `extend` or `prepend` (calls run a copy made for each class it is mixed into) | **warning** naming the mixin; ignored. The same signature through `--rbs` is not applied either: it reaches the module's own method, which is copied away. A `module_function` (or `extend self`) method is applied, since its one function serves every caller |
| An annotated `def` that a later definition of the same method replaces -- a `def` in a reopened class, a `def` in a `class_eval` block, a `define_method` -- when that definition has no applied annotation of its own (none, one that is ignored, or one naming a type Spinel cannot pin) | **warning** naming the replacement; ignored, since the annotated code never runs |

An error stops the compile; a warning does not, and the program compiles as
it would without the annotation. Messages look like
`spinel: FILE:LINE:COL: warning: inline RBS: ... is not applied: ...`,
where COL is the column of the comment's `#`, and a type is named as the
comment wrote it.

These are never annotations, and are not reported:

- RDoc directives: `#:nodoc:`, `#:yields:`, `#:call-seq:`, `#:stopdoc:` and
  the rest of RDoc's `:name:` list. None of them is valid RBS.
- Prose, magic comments (`# frozen_string_literal:`, `# typed:`),
  `# spinel:` directives, and comments that only mention `#:` or `@rbs`
  after other text.
- `#` inside strings, heredocs, `%`-literals and regexps, and anything in a
  `=begin`/`=end` block.
- Sorbet and YARD doc tags such as `# @abstract`, `# @override`, `# @final`.
- Comments in source compiled at build time from a string (`class_eval`).

## With `--rbs`

Both may be used together. Where an annotation and a `.rbs` signature say
something about the same slot they must agree, and then the program compiles
as with either alone; where they disagree the compile stops and names both.
A `.rbs` directory generated from the annotations is therefore harmless.

The same rule holds between two annotations of one method: a method
annotated in two openings of its class, or a `def` replaced by a later
annotated `def`, compiles when the two say the same thing and is refused,
naming both, when they do not. Agreement compares the types themselves, so
`Array[Foo]` and `Array[Bar]` disagree, as do `Integer` and `Integer?`.
An annotation that is not applied, for whatever reason it was reported,
takes part in neither comparison.

Two `.rbs` declarations of one method that differ are refused by `--rbs`
itself, naming both, before any annotation is compared with them. An
annotation that agrees with one of the two does not choose between them.

## Turning it off

`--no-inline-rbs` compiles the program as if it had no annotations: nothing
is applied and nothing is reported. Use it for code whose annotations were
written for another checker and are not trusted to describe the program.
`--rbs` still works with it.

## Compatibility matrix

Every inline form either reference documents, and what Spinel does with it.
The type grammar is ruby/rbs's, and the comment surface Sorbet's; where they
differ the row names the one followed. The references were read as of
ruby/rbs `master` at `bf6ca576` (the parser Spinel links is the 4.0.1 release
`make deps` fetches) and Sorbet's
[RBS comments](https://sorbet.org/docs/rbs-support) page as of 2026-10-06.

*Implemented* forms are applied as described above. *Deferred* forms are
recognised and reported with a warning, and the program compiles as without
them. *Ignored* forms are documentation and draw no message. No form is
incompatible with Spinel as such; `#: as untyped` is the nearest, since its
meaning ("stop checking this") has no counterpart in a compiler that does
not check.

| Form | Spelling | Source | Status | Why |
|---|---|---|---|---|
| Method type | `#: (Integer) -> String` above `def` | both | implemented | the seed a `.rbs` `def` gives |
| Method of a mixed-in module | any method type above a `def` in a module that is included, extended or prepended | both | deferred | the calls run per-class copies no seed reaches, with `--rbs` as well; seeding every copy, for both, is a separate change |
| No parameters | `#: -> void` | Sorbet | implemented | as above |
| `@rbs` method type | `# @rbs (Integer) -> Integer` | ruby/rbs | implemented | as above |
| Overloads | several `#:` lines; `\|` in `# @rbs` | both | deferred | a seed has one signature, and keeping the first would apply part of the annotation |
| Super-type overload | `# @rbs ... \| ...`, `# @rbs ...` | ruby/rbs | deferred | needs the super method's type |
| Continuation with `#\|` | `#: (Integer,` / `#\|  String) -> void` | Sorbet | implemented | joined, then read as one method type |
| Continuation by indentation | `# @rbs (Integer,` / `#   String) -> void` | ruby/rbs | implemented | as above |
| Parameter and return lines | `# @rbs x: Integer`, `# @rbs return: String` | ruby/rbs | implemented | matched to the `def`'s parameters by name |
| Rest and block parameter lines | `# @rbs *a: T`, `**b: T`, `&block: T` | ruby/rbs | deferred | rest and block parameters are not seeded |
| Trailing return | `def m(x) #: Integer` | ruby/rbs | implemented | the return seed |
| Endless `def` | `def m(x) = x #: Integer` | ruby/rbs `master` | implemented | the return seed |
| Class method | above `def self.m` | both | implemented | the class-method seed |
| `class << self` | above a `def` inside it | Sorbet | implemented | the class-method seed |
| Skip | `# @rbs skip` | ruby/rbs | implemented | no fact for that declaration |
| Generic method | `#: [U] (U) -> U` | Sorbet | deferred | type variables are not representable |
| Optional, rest, trailing, rest-keyword, block parameters | `(?Integer)`, `(*Integer)`, `?k: T`, `**T`, `{ ... }` | both | deferred, whole signature | `--rbs` drops these signatures; inline says so |
| Block `self` type | `{ () [self: T] -> void }` | both | deferred | blocks are not seeded |
| Modifiers | above `private def m` | both | implemented | attaches to the `def` |
| Attribute, trailing | `attr_reader :x #: String` | ruby/rbs | implemented | the ivar seed of each name |
| Attribute, leading | `#: String` above `attr_reader :x` | Sorbet | implemented | as above |
| Instance variable | `# @rbs @x: String` in a class body | ruby/rbs | implemented | the ivar seed |
| Instance variable write | `@x = v #: T` in an instance method | Sorbet | implemented, as a declaration | the ivar seed; not a check of that one write |
| Class-level instance variable | `@x = v #: T` in a class body or class method; `# @rbs @x: T` in `class << self` | both | deferred | a class's own variables are not seeded |
| Constant | `X = 42 #: Integer` | both | deferred | constants are not seeded; a literal constant is inferred already |
| Alias | `#: class-alias`, `#: module-alias` | ruby/rbs | deferred | no use in compilation |
| Local variable | `x = v #: T` | Sorbet | deferred | needs a type held for one local through inference |
| Cast | `expr #: as T` | Sorbet | deferred | needs a type for one expression |
| Non-nil cast | `expr #: as !nil` | Sorbet | deferred | as above |
| Untyped cast | `expr #: as untyped` | Sorbet | deferred | see above |
| Absurd | `x #: absurd` | Sorbet | deferred | exhaustiveness is a checker's feature |
| `self` binding | `#: self as T` | Sorbet | deferred | needs `self` typed in `instance_eval` blocks |
| Generic instance | `Box.new #: Box[Integer]` | Sorbet | deferred | generic classes are not modelled |
| Generic class | `#: [E]` above `class` | Sorbet | deferred | as above |
| Type alias | `#: type t = ...` | Sorbet | deferred | not seeded |
| Superclass and mixin arguments | `class A < B #[T]`, `include M #[T]` | ruby/rbs | deferred | mixins are not modelled |
| Module self type | `# @rbs module-self: T` | ruby/rbs `master` | deferred | not in 4.0.1; mixins are not modelled |
| Types outside the subset | interfaces, literals, tuples, records, procs, `self`/`instance`/`class`, `top`/`bot`, type variables, in any form | both | deferred, whole annotation | not representable |
| Doc tags | `# @abstract`, `# @override`, `# @overridable`, `# @final`, `# @interface`, `# @sealed`, `# @requires_ancestor:` | Sorbet | ignored | the same spellings are YARD doc tags |
| RDoc directives | `#:nodoc:`, `#:yields:`, ... | -- | ignored | none is valid RBS |
| Comments in `class_eval` strings | `class_eval "..."` | -- | ignored | parsed apart from the program's comments |

## What a signature buys

An annotation gives the compiler a type inference could not find. Where
inference already has the type it changes nothing; where it does not, a
slot that was a boxed value -- a tagged value every operation on which is
dispatched at run time -- becomes the declared C type.

`benchmark/bm_rbs_items.rb` is one such call site. `Bag#items` returns
`@items || EMPTY`, and some bags hold no array, so without its
`#: -> Array[Integer]` the `.size` in the hot loop compiles to
`sp_poly_size`, a dispatch on a boxed value; with it, to
`sp_IntArray_length`. `make bench-rbs` (`tools/rbs_bench.rb`) builds that
program without RBS, with the annotation, and with the same signature
through `--rbs`, and beside them `benchmark/bm_rbs_items_control.rb`, the
same loop over a method inference already types precisely. On one Linux
x86-64 machine, gcc 14 at `-O2`, 21 interleaved runs of 200 million
iterations each (load average about 5 on 32 cores):

| Build | Hot `.size` | Binary bytes | `.text` bytes | Median s | Min s | Max s |
|---|---|---:|---:|---:|---:|---:|
| no RBS (`--no-inline-rbs`) | `sp_poly_size` | 359,448 | 198,834 | 0.955 | 0.858 | 1.053 |
| inline annotation | `sp_IntArray_length` | 354,816 | 195,826 | 0.589 | 0.585 | 0.605 |
| same signature via `--rbs` | `sp_IntArray_length` | 354,816 | 195,826 | 0.591 | 0.586 | 0.601 |
| control | `sp_IntArray_length` | 350,600 | 194,674 | 0.173 | 0.169 | 0.185 |

The inline and `--rbs` builds are the same C, byte for byte, and the
control's C is the same with its annotation and without. Every build's
stdout, stderr and exit status equal CRuby's. The unannotated build is also
the noisy one: its runs spread from 0.86 to 1.05 s where the annotated ones
stay within 4%, and its fastest run is still slower than the annotated
builds' slowest. The distance left between the annotated loop and the
control is `@items || EMPTY` itself: the instance variable is still a boxed
value inside `items`, and is unboxed at the return.

These numbers describe one loop on one machine. They show what one
signature does to one call site; they are not a measure of how much faster
a program gets, which depends on how much of its time is spent in slots
inference could not type.

## Limitations

- A method's annotation reaches its method through the `def` itself, and a
  class-level annotation its class through the class body it is written in,
  so reopened classes, `class << self`, renamed same-named classes and the
  bodies of `Struct.new`, `Class.new` and `Data.define` need no name matching.
  Class names inside types (`#: () -> Item`) are resolved as `--rbs` resolves
  them.
- The reference grammar is the vendored `ruby/rbs` 4.0.1 parser, which the
  compiler links when built after `make deps`. A compiler built from the
  Prism gem alone cannot read annotations, and says so at the first one.
