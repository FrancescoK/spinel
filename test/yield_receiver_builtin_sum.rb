# sum on a yield receiver, default (raise) mode: an Integer Array site
# answers Integer (unboxed) and a Float Array site answers poly (CRuby's own
# `0 + 1.5` seed/element mismatch, not a receiver-follows rule -- confirmed
# with --emit-types on a direct, non-yield `[1.5].sum`), so the two sites
# disagree on boxedness, the same shape every other K-024 leftover-scope
# builtin disagrees on (K-024, kilau docs/CATALOG.md).
def sum_of = yield.sum
p sum_of { [1, 2, 3] }
p sum_of { [1.5, 2.5] }
