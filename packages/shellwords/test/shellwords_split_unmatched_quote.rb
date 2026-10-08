# A quote Shellwords.split never sees closed is an ArgumentError, and the
# message gives the position where the unmatched part starts (#1134).
# spinel: share
require "shellwords"

[%q(a "unterminated), %q(it's), %q(ok 'open), %q(")].each do |line|
  begin
    Shellwords.split(line)
  rescue ArgumentError => e
    p e.message
  end
end
