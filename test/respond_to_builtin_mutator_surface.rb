# sp_poly_responds_builtin's per-class method tables (lib/spinel_rt.h) named
# only a fraction of each builtin's real surface, against bop_rows's own
# templates -- Array alone was missing 67 names, including every bang
# mutator (uniq!, sort!, compact!, ...). A boxed receiver's respond_to?(:m)
# for a real, implemented method answered false, which this repro's shape
# (gem "jaccard") hit for real: Jaccard.coefficient's `union.uniq! if
# union.respond_to?(:uniq!)` silently stopped deduping once `union`'s
# parameter was boxed by an unrelated call site, so the coefficient came out
# wrong (3/7 instead of 3/4).

def force_poly(mixed, idx)
  mixed[idx]
end

# Array: the exact jaccard shape (uniq! via respond_to?, plus a sample of
# the other newly-covered bang mutators).
a = force_poly([[1, 2, 3, 4], "x"], 0)
union = a + [1, 3, 4]
p union.respond_to?(:uniq!)
union.uniq! if union.respond_to?(:uniq!)
p union
p force_poly([[1, 2], "x"], 0).respond_to?(:sort!)
p force_poly([[1, 2], "x"], 0).respond_to?(:compact!)
p force_poly([[1, 2], "x"], 0).respond_to?(:flatten!)
p force_poly([[1, 2], "x"], 0).respond_to?(:select!)
p force_poly([[1, 2], "x"], 0).respond_to?(:member?)

# Hash
p force_poly([{ "a" => 1 }, "x"], 0).respond_to?(:compact!)
p force_poly([{ "a" => 1 }, "x"], 0).respond_to?(:transform_keys!)
p force_poly([{ "a" => 1 }, "x"], 0).respond_to?(:except)

# String
p force_poly(["abc", 1], 0).respond_to?(:upcase!)
p force_poly(["abc", 1], 0).respond_to?(:strip!)
p force_poly(["abc", 1], 0).respond_to?(:each_byte)

# Integer / Float
p force_poly([1, "x"], 0).respond_to?(:gcdlcm)
p force_poly([1, "x"], 0).respond_to?(:infinite?)
p force_poly([1.5, "x"], 0).respond_to?(:next_float)

# Range
p force_poly([(1..5), "x"], 0).respond_to?(:filter_map)
p force_poly([(1..5), "x"], 0).respond_to?(:max_by)

# Symbol
p force_poly([:sym, 1], 0).respond_to?(:casecmp)
p force_poly([:sym, 1], 0).respond_to?(:slice)

# Proc
p force_poly([proc {}, 1], 0).respond_to?(:source_location)

# Negative controls: a real method name no class defines; an Exception
# accessor that is real but gated to one subclass (a generic exception
# must NOT answer true for it just because the name exists somewhere in
# bop_rows); and format, a Kernel method (BOP_KERNEL in bop_rows), not a
# String instance method -- "x".respond_to?(:format) is false in CRuby,
# so it must not be read off bop_rows's TY_STRING rows either.
p force_poly([[1, 2], "x"], 0).respond_to?(:not_a_real_method)
p force_poly([RuntimeError.new, 1], 0).respond_to?(:errno)
p force_poly(["abc", 1], 0).respond_to?(:format)
