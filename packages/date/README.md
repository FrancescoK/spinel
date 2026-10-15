# date

`require "date"`: Date and DateTime, from ruby/date's pure-Ruby
implementation, vendored unchanged.

- Source: <https://github.com/ruby/date/pull/155> (Feature #21264, "Replace C
  extension with pure Ruby implementation for Ruby >= 3.3")
- Commit: `8795e36106c80dceb44650424c5fadbbc0436c35` (2026-06-30)
- Files: `lib/date.rb` is `date.rb` here, `lib/date/*.rb` is `date/*.rb`
- License: Ruby's (`COPYING`) or the 2-clause BSD license (`BSDL`), both
  copied from that commit

When the pull request is merged upstream, replace these files with the
released gem's `lib/` and update the commit above.

The tests in `test/` run on demand, not in the gate:
`make pkg-ondemand-test`.
