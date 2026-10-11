# spinel: int64
# A Range argument to zip begins at -2**63 or ends at 2**63-1 as any other
# Range does: only a beginless one cannot be iterated, and only an endless
# one runs on past its receiver.
n = ARGV.size
lo = -9223372036854775807 - 1 - n
hi = 9223372036854775807 - n
p [1, 2, 3].zip(lo..0)
p [1, 2, 3, 4].zip(hi - 2..hi)
p [1, 2].zip(5 + n..)
