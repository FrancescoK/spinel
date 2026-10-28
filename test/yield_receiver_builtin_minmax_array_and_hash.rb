# minmax on a yield receiver, across Array sites of different element kind
# and a Hash site too -- the last of kilau's K-033 names.
#
# minmax was never listed in yield_site_listed at all (unlike min/max,
# which were), so even two plain Array sites of a different element kind
# failed to compile -- a plainer bug than the Hash-specific extension
# below. Once minmax is listed for a plain Array receiver the same way
# min/max already were, the per-site widening mechanism
# (yield_recv_builtin_every_site) can also see a Hash site answered
# through the same TY_POLY_ARRAY redirect min/max/uniq already use
# (hash_enum_redispatch's own reasoning in analyze_infer.c, materializing
# the Hash's [key, value] pairs as a Poly Array), closing minmax for
# every combination.
def t_minmax = yield.minmax
p t_minmax { [3, 1, 2] }
p t_minmax { ["b", "a"] }
p t_minmax { { a: 1, b: 2 } }
