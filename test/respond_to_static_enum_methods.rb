# respond_to?(:tally) / respond_to?(:transform_keys!) / respond_to?(:transform_values!)
# on a concrete (never-boxed) receiver -- answered by
# respond_to_static_answer/rt_probe_answer in src/codegen_call.c, a
# different mechanism from respond_to_generated_tables.rb's boxed path.
# (K-026 cause A, kilau docs/CATALOG.md.)
#
# desugar_respond_to_probe synthesizes its probe calls during the
# analyzer's fixpoint. The rewrites that make these methods actually
# type (desugar_builtins' per-call-site clone for the generic
# Enumerable-sourced names, desugar_enum_chain_shapes's bang-form
# rewrite for transform_keys!/transform_values!) each run exactly once,
# in a pre-pass before any scope -- and so before any probe -- exists.
# A probe created later never gets rewritten, falls through to
# bop_rows's TY_UNKNOWN placeholder row, and respond_to? read that as
# untyped: false, where CRuby answers true.

a = [1, 2, 3]
p a.respond_to?(:tally)

h = { "a" => 1, "b" => 2 }
p h.respond_to?(:tally)
p h.respond_to?(:transform_keys!)
p h.respond_to?(:transform_values!)

r = (1..3)
p r.respond_to?(:tally)

class HasOwnTally
  def tally = "mine"
end
p HasOwnTally.new.respond_to?(:tally)
