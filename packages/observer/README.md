# observer

`require "observer"`: Observable, ruby/observer's implementation of the
observer pattern (a bundled gem since Ruby 3.4), vendored unchanged.

- Source: <https://github.com/ruby/observer>, release v0.1.2, the version
  CRuby 4.0 bundles
- Commit: `6c978e6196b33405aced08ca3c3a5600f5b271e5` (2023-11-07)
- Files: `lib/observer.rb` is `observer.rb` here
- License: Ruby's or the 2-clause BSD license (the gemspec); `LICENSE.txt`,
  the BSD text, is copied from that commit

To update, replace `observer.rb` with a newer release's `lib/` and update
the commit above.

The tests in `test/` run on demand, not in the gate:
`make pkg-ondemand-test`.
