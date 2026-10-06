# The omitted endpoint of a beginless or endless Float Range is nil. Read
# into a boxed slot (an Array or Hash literal, a poly local) it was boxed as
# a plain Float and printed NaN, where CRuby answers nil; printed directly
# or kept in a Float local it was already nil.

endless_flt = (1.0..)
beginless_flt = (..2.5)
p [endless_flt.end, endless_flt]
p [beginless_flt.begin, beginless_flt]
p [endless_flt.begin, endless_flt.end, beginless_flt.begin, beginless_flt.end]
p({b: beginless_flt.begin, e: endless_flt.end})
p [endless_flt.end.nil?, beginless_flt.begin.nil?]
mixed = [1, endless_flt.end]
p mixed
endless_end = endless_flt.end
p endless_end
p [(1.5...).end, (...3.5).begin]

# a bounded Float Range keeps its endpoints
bounded_flt = (1.5..2.5)
p [bounded_flt.begin, bounded_flt.end]
p({b: bounded_flt.begin, e: bounded_flt.end})
