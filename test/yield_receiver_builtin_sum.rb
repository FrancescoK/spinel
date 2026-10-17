# sum on a yield receiver, default (raise) mode: an Integer Array site
# answers Integer (unboxed) and a Float Array site answers poly -- Spinel's
# own fold_sum_type, not CRuby's answer (CRuby's [1.5].sum is Float 4.0):
# the default Integer(0) seed's type mismatch with a Float element, not a
# receiver-follows rule (confirmed with --emit-types on a direct, non-yield
# `[1.5].sum`) -- so the two sites disagree on boxedness, the same shape
# dig and succ (see the other tests beside this one) disagree on too.
def sum_of = yield.sum
p sum_of { [1, 2, 3] }
p sum_of { [1.5, 2.5] }
