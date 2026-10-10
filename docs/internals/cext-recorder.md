# C extension recorder (step 4 of #7210)

The recorder executes an extension's `Init_*` during an explicitly requested
build step. It records definitions, not Ruby execution. This is a foundation
for the later compiler bridge: it does not yet make `require` load extensions.

```
ruby tools/cext-record.rb --name sample --init Init_sample \
  --output build/sample.json --declarations build/cext_sample.rb \
  --object-archive build/sample.a \
  test/cext/recorder/definitions.c
```

The output directories must exist. The tool needs a host Ruby, a native C11
compiler, `nm` and `ar`. `--cc` (or `CC`) chooses the compiler; repeat
`--cflag -Ipath`, `--cflag -DNAME=value` or `--cflag -UNAME` for include paths
and preprocessor settings. Arguments are passed directly, without a shell.
Other flags and native library imports are outside this initial subset.
`make cext-recorder` also builds the standalone `libspinel_cext_rec.a`.
Neither archive nor recorder sources enter the regular Spinel runtime.

## Build sequence

1. Preprocess each source with the restricted header and scan the resulting C
   tokens. This sees macro-expanded calls and adjacent string literals, and
   skips system/restricted-header declarations. Literal `rb_intern` names and
   literal `rb_funcall` argument counts form the future send-table inputs.
   Computed `rb_intern` arguments/argument counts and taking these API function
   addresses refuse. This collects dispatch inputs; full ID-flow checking is
   part of the later send-table bridge.
2. Compile every extension translation unit once. Check its external imports
   against the recorder's definitions, cross-unit extension definitions and a
   small list of deterministic memory/string helpers. Environment, files,
   clocks, dynamic loading, unknown Ruby/native APIs and inline assembly refuse.
   This conservative check also applies to unexecuted method bodies. Additional
   APIs/native dependencies must be deliberately integrated in later steps.
3. Link those objects with `libspinel_cext_rec.a` and a generated `Init_*`
   launcher. Run it in a child process, with a ten-second limit. Ruby execution
   (`rb_funcall`, `rb_const_get`, `rb_eval_string`, protection/exception APIs,
   error-state reads) refuses when reached during initialization. Such calls in
   registered method bodies are not executed by the recorder.
4. Only after success, publish JSON and optional generated Ruby declarations.
   A refused/crashed/timed-out initializer leaves existing artifacts intact.
   `--object-archive` retains the exact extension objects for later program
   linking. Remaining scratch objects, recorder archive and launcher are
   removed on either outcome.

This executes opted-in native source, as building native source already does;
it is not a security sandbox for untrusted C. The import check is a restricted
API boundary, not a proof about arbitrary C or undefined behavior. The compiler
bridge must reuse the retained extension object archive and registration order, rather than
recompile initialization with different settings or add a startup mismatch
abort. Ordinary builds never invoke this tool.

## Manifest version 1

The top-level fields are `version`, `extension`, `init`, `definitions`,
`literal_ids` and `funcall_arities`. Definition events preserve execution
order. No temporary paths, timestamps, pointer addresses or platform ABI names
are stored. Function references are zero-based registration slots, including
allocator registrations. Module functions produce a private instance-method
registration and a public singleton-method registration.

Supported events:

| Kind | Fields in addition to `kind` and qualified `owner` |
| --- | --- |
| class | `name`, `path`, `superclass` |
| module | `name`, `path` |
| method | `name`, `scope`, `visibility`, `arity`, `function` |
| allocator | `function` |
| constant | `name`, `value` |
| alias | `name`, `original` |
| attribute | `name`, `read`, `write` |
| include / extend | `module` |

Constant values have `type` equal to integer, boolean, nil, symbol, reference
(a qualified class/module name), or string. Strings store arbitrary bytes as
`hex`, an `object` identity slot and `frozen`; their encoding is ASCII-8BIT.
Freeze strings before publishing them as constants. Freezing an already
published mutable string refuses, since its earlier event would otherwise
have stale state. Class/module names are restricted to ASCII constant names; other metadata
names are ASCII, and scanned IDs are printable ASCII.
Reopening the same class/module preserves identity; a kind or superclass
mismatch refuses. Redefining known builtin classes/modules, or defining through
a constant alias or a non-class/module constant, also refuses in this subset. Unsupported constant values and object-layout access refuse.

`__cext_extension`, `__cext_class`, `__cext_module`, `__cext_method`, and the
corresponding event declarations carry these facts as literal Ruby arguments.
`__cext_constant` arguments are owner, name, value type, payload, optional
string identity and optional frozen flag; a string payload is hex. Separate
`__cext_literal_id` / `__cext_funcall_arity` declarations carry scan inputs.
These are a versioned compiler input contract, not executable Ruby APIs. The
next PR adds their consumption and real Ruby-to-C dispatch. There is no automatic
`spin build`/`spin.toml` integration in this stage; that belongs to package building.

## Checks

`make cext-recorder-test` checks deterministic artifacts, macro/loop definitions,
reopening, binary strings/identity, argument scanning, multi-source helpers,
and explicit refusals while preserving artifacts. It is also part of `make test`.
`make cext-recorder-oracle` builds the same fixture as a real CRuby extension
and compares class hierarchy, methods/visibility/arity, constants/encoding,
aliases, attributes, include/extend and shared string identity.
