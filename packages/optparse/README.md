# optparse

`require "optparse"`: OptionParser, ruby/optparse's own source at the version
CRuby 4.0 ships.

- Source: <https://github.com/ruby/optparse>, release v0.8.1, commit
  `f2e31e81a50cb3c7c7e8523c41497c7588bc5669` (2025-12-10). `lib/optparse.rb`
  is `optparse.rb` here, `lib/optparse/*.rb` is `optparse/*.rb`.
- License: Ruby's (`COPYING`) or the 2-clause BSD license (`BSDL`), both
  copied from that commit.

`optparse/*.rb` is unchanged except that five of them (`ac.rb`, `date.rb`,
`shellwords.rb`, `time.rb`, `uri.rb`) lose their first line,
`# frozen_string_literal: false`: Spinel freezes every string literal and
warns that the pragma is ignored, so it warned in every program that
required one of them, and their literals are frozen either way.
`version.rb` is left out: it is what `--version=pkg` loads (see below), and
a program that required it did not compile.
`optparse.rb` is unchanged except for these hunks, each in its own commit
with the reason:

| Where | Upstream | Here | Why |
|---|---|---|---|
| `Completion.candidate` and its three callers | the table's `&method(:each)` as a block, called with a block | the table as an argument, iterated with `#each` | a Method given as such a block raises NoMethodError |
| `RequiredArgument#parse`, `parse_in_order` | `&method(:raise)`, `{\|*exc\| raise(*exc)}` | `{ \|klass, word\| raise klass, word }` | a splatted `raise` raises TypeError |
| `List#accept`, `make_switch` | `pattern.method(:convert).to_proc` | `->(*a) { pattern.convert(*a) }` | refused on a pattern of several classes |
| `visit` | `el.__send__(id, *args, &block)` | a `case` calling each method by name | the block did not arrive |
| pager of `--help` | a branch under `if ... and false` with `Process.exec(..., in: f)` | removed | `exec` with options is refused, even dead |
| pager of `--help` | `IO.popen(*args, &print)` | `Process.spawn` of the pager reading an `IO.pipe` | `IO.popen` with a write mode is not supported; through the splat it raised ArgumentError on a terminal with `PAGER` set |
| `--version` | `--version=pkg` loads `optparse/version` | the package name is ignored | that file finds versions by constant names at run time |
| `warn`, `abort` | `super("#{program_name}: #{mesg}")` | write the line to `$stderr`; `abort` then raises `SystemExit` | `super` did not reach `Kernel#warn` and `Kernel#abort` (NoMethodError) |
| long switches in `parse_in_order` | `sw.parse(rest, argv)` | `sw.parse(rest ? rest : nil, argv)` | a nil `rest` crashed a switch with an optional value |
| top of the file | nothing: CRuby loads did_you_mean before the program | `require 'did_you_mean'` | an invalid or ambiguous option names the switches it could have meant |
| end of the file | `ARGV.extend(OptionParser::Arguable)` | removed | `extend` on one object is refused |

So `ARGV.options`, `ARGV.parse!` and `ARGV.getopts` are not available,
and `--version=pkg` prints the program's own version. Everything else the
gem's documentation shows works as in CRuby, `accept`, Regexp and Range
patterns, `optparse/date`, `optparse/time`, `optparse/uri` and
`optparse/shellwords` included.

To update, replace these files with a newer release's `lib/`, carry the hunks
above over (the commits that made them are the list), and update the commit.

The tests in `test/` run in the gate, with `.expected` from CRuby 4.0.
