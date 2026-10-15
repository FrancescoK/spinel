# getoptlong

`require "getoptlong"`: GetoptLong, ruby/getoptlong's command-line option
parser (a bundled gem since Ruby 3.4), vendored unchanged.

- Source: <https://github.com/ruby/getoptlong>, release v0.2.1, the version
  CRuby 4.0 bundles
- Commit: `f49629dfaa17b2dbb8c776ff9bf52ef8a050c19a` (2023-11-07)
- Files: `lib/getoptlong.rb` is `getoptlong.rb` here
- License: Ruby's or the 2-clause BSD license (the gemspec); `LICENSE.txt`,
  the BSD text, is copied from that commit

To update, replace `getoptlong.rb` with a newer release's `lib/` and update
the commit above.

The tests in `test/` run on demand, not in the gate:
`make pkg-ondemand-test`.
