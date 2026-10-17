# succ on a yield receiver: a Symbol site answers Symbol, same as an
# Integer or String site (found in review of the succ arm: Symbol#succ has
# its own fixed-result bop row, like String's, so it belongs beside it).
def succ_of = yield.succ
p succ_of { 5 }
p succ_of { :a }
