# A sample from each of the five classes this generates a respond_to?
# table for (see docs/superpowers/specs/2026-10-12-generate-respond-to-
# tables-design.md), forced boxed the same way
# test/respond_to_builtin_mutator_surface.rb does (respond_to? on a typed,
# never-boxed receiver goes through a different mechanism entirely --
# respond_to_static_answer in src/codegen_call.c -- not this one).
def force_poly(mixed, idx) = mixed[idx]

samples = {
  force_poly([[1, 2], "x"], 0) => %w[uniq! transpose to_set],
  force_poly([{ a: 1 }, "x"], 0) => %w[transform_keys! to_set],
  force_poly(["ab", 1], 0) => %w[delete_prefix! unicode_normalize],
  force_poly([5, "x"], 0) => %w[digits ceildiv],
  force_poly([1.5, "x"], 0) => %w[next_float prev_float],
}
samples.each do |recv, names|
  names.each { |n| p [recv.class, n, recv.respond_to?(n)] }
end
# Kernel and compiler-internal names must stay excluded for every class.
p force_poly([1.5, "x"], 0).respond_to?(:format)
p force_poly([[1, 2], "x"], 0).respond_to?(:__bivar_get)
