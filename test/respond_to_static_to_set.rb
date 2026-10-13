# respond_to?(:to_set) on a concrete (never-boxed) receiver, answered by
# respond_to_static_answer/rt_probe_answer in src/codegen_call.c -- a
# different mechanism from respond_to_generated_tables.rb's boxed path.
#
# Array/Hash (K-026, cause A): the analysis-only probe
# desugar_respond_to_probe synthesizes always carries an ArgumentsNode,
# even for its no-argument shapes, so gating the to_set ==
# Set.new(to_a) rewrite (src/analyze.c) on "no ArgumentsNode at all"
# never matched the probe and answered false where CRuby answers true.
#
# Range (K-026, cause B): a concrete Range answers respond_to? from the
# same hand-maintained rngm[] table a boxed Range does
# (sp_poly_responds_builtin, lib/spinel_rt.h) rather than through the
# probe/rewrite above at all -- "to_set" was simply missing from that
# table, so every Range (boxed or not) answered false.
require "set"

p [1, 2, 3].respond_to?(:to_set)
p({ "a" => 1 }.respond_to?(:to_set))
p (1..3).respond_to?(:to_set)

def force_poly(mixed, idx) = mixed[idx]
p force_poly([(1..3), "x"], 0).respond_to?(:to_set)

class HasOwnToSet
  def to_set = "mine"
end
p HasOwnToSet.new.respond_to?(:to_set)

p Set.new([1, 2]).respond_to?(:to_set)
