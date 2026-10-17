# date

`require "date"`: Date and DateTime, from ruby/date's pure-Ruby
implementation, with the changes below.

- Source: <https://github.com/ruby/date/pull/155> (Feature #21264, "Replace C
  extension with pure Ruby implementation for Ruby >= 3.3")
- Commit: `8795e36106c80dceb44650424c5fadbbc0436c35` (2026-06-30)
- Files: `lib/date.rb` is `date.rb` here, `lib/date/*.rb` is `date/*.rb`
- License: Ruby's (`COPYING`) or the 2-clause BSD license (`BSDL`), both
  copied from that commit

Changes from that commit, each answering as before, so the compiler can
type and share what the code holds (to be offered upstream):

- a Date's Julian day, cutover and DateTime's time fields are stored as
  `Integer(...)` / `Float(...)` / `Rational(...)` of what they are given;
- `initialize_copy` reads the copied fields through protected readers, and
  `new_start`, `step`, `upto` and `downto` set them through a protected
  setter, not `instance_variable_get` / `instance_variable_set`;
- `sp_complete_frags` asks today's fields by name in a `case`, not by
  `__send__(sym)`;
- each `StringScanner` scans a copy of its String, and a parsed zone is
  read as `String(...)`;
- `deconstruct_keys`' `each` block ends in `nil`.

When the pull request is merged upstream, replace these files with the
released gem's `lib/`, keep the changes upstream has not taken, and update
the commit above.

The tests in `test/` run on demand, not in the gate:
`make pkg-ondemand-test`.
