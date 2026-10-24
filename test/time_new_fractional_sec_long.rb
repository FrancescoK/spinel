# spinel: int64 -- a ten-digit Rational fraction is n / 10**10, past 2^31
# A fraction just under or over a whole nanosecond is truncated, never
# rounded up to a second, in Time.new and Time.utc.
p Time.new(2026, 3, 4, 10, 20, 30.9999999996r).nsec
p Time.new(2026, 3, 4, 10, 20, 30.9999999996r).sec
p Time.new(2026, 3, 4, 10, 20, 30.0000000006r).nsec
p Time.utc(2026, 3, 4, 10, 20, 30.9999999996r).nsec
p Time.utc(2026, 3, 4, 10, 20, Rational(999999999999999999, 1000000000000000000)).nsec
p Time.utc(2026, 3, 4, 10, 20, Rational(999999999999999999, 1000000000000000000)).sec
