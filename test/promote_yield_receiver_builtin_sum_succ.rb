# sum/succ on a yield receiver under --int-overflow=promote: an IntArray sum
# and an Integer succ both answer poly (Bignum-capable); a FloatArray sum and
# a String succ are unaffected by promote mode. sum_of pins promote's
# threading into the sum arm (an Integer Array site here only differs from
# raise mode through that arm); succ_of2 below does the same for succ,
# since succ_of alone passes even if succ's promote arm answered a flat
# Integer instead (its Integer site here is small enough not to overflow).
def sum_of = yield.sum
p sum_of { [1, 2, 3] }
p sum_of { [1.5, 2.5] }

def succ_of = yield.succ
p succ_of { 5 }
p succ_of { "az" }

# a non-constant Integer at the word's max, beside a String site: only
# succ's promote arm (not a flat Integer answer) keeps this a Bignum
# instead of a raise-mode RangeError.
def succ_of2 = yield.succ
p succ_of2 { 9223372036854775807 - 0 }
p succ_of2 { "zz" }
