# succ on a yield receiver: an Integer site answers Integer, a String site
# answers String, in raise (default) mode (K-024 leftover scope).
def succ_of = yield.succ
p succ_of { 5 }
p succ_of { "az" }
