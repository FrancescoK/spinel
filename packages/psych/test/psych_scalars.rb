# Plain scalars resolve as Psych's ScalarScanner resolves them (YAML 1.1's
# booleans and integer forms included); a quoted scalar is always a String.
require "psych"

[
  "", "~", "null", "NULL", "true", "TRUE", "yes", "On", "no", "off", "y", "n",
  "1", "-1", "+1", "0x1f", "0o17", "017", "08", "0b101", "1_000", "1,000", "0",
  "1.5", ".5", "1.", "1e3", "1.0e+3", ".inf", "-.inf", ".NaN", "1:30", "12:30:45",
  "abc", "'q'", "\"a\\tb\\u00e9\\n\"", "'it''s'", "\"x\\x41\\u263A\"", "C:\\path", "a:b"
].each { |s| puts "#{s.inspect} => #{Psych.safe_load(s).inspect}" }
