# map! over a local whose element was read out before the replacement: the
# String it handed out is the one map!'s block mutates in place. Refused,
# not silently applied to a copy.
# spinel: reject-thread-string
parts = " a , b ".split(",")
first = parts[0]
parts.map! { |x| x.strip! || x }
p first, parts
