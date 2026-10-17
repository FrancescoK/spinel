# sum/succ on a yield receiver under --int-overflow=promote: an IntArray sum
# and an Integer succ both answer poly (Bignum-capable); a FloatArray sum and
# a String succ are unaffected by promote mode (K-024 leftover scope).
def sum_of = yield.sum
p sum_of { [1, 2, 3] }
p sum_of { [1.5, 2.5] }

def succ_of = yield.succ
p succ_of { 5 }
p succ_of { "az" }
