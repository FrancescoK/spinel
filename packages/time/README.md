# time

`require "time"`: `Time.parse` and `Time.strptime`, from CRuby's
`lib/time.rb`, vendored unchanged.

- Source: CRuby 4.0.7, `lib/time.rb` (time 0.4.2)
- License: Ruby's (`COPYING`) or the 2-clause BSD license (`BSDL`)

The file is spliced in only when the program calls `Time.parse` or
`Time.strptime`; `require "time"` alone stays the runtime's.

To update, replace `time.rb` with a newer CRuby's `lib/time.rb`.
