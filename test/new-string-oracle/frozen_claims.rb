# A String that is claimed frozen is. frozen_claims.claims claims it of a
# literal (frozen under --enable-frozen-string-literal) and of an ENV String,
# which are, and of a `+"..."` String and of an unfrozen copy, which are not;
# the oracle must disprove those two. A nil (a missing ENV key) is no String.
lit = "literal"
env = ENV.fetch("PATH", "")
missing = ENV["SP_ORACLE_NO_SUCH_KEY"]
mutable = +"mutable"
copy = lit.dup
p lit.frozen?, env.frozen?, missing, mutable.frozen?, copy.frozen?
