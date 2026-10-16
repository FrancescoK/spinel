# private/protected reopening of an EXISTING builtin method (no redefinition,
# just `private :first`) was tracked only for method_defined?/
# private_method_defined? (src/codegen_call_class.c's method_defined? family,
# via comp_method_vis_declared), not consulted by respond_to? or by the
# direct-call visibility check (emit_vis_refusal, src/codegen_call.c) for a
# receiver typed as a builtin (Array, Hash, ...) rather than TY_OBJECT.
# (K-028, kilau docs/CATALOG.md.)

class Array
  private :first
end
begin
  p [1, 2, 3].first
rescue NoMethodError => e
  p e.message
end
p [1, 2, 3].respond_to?(:first)
p [1, 2, 3].respond_to?(:first, true)
p [1, 2, 3].send(:first)

class Hash
  protected :fetch
end
begin
  p({ "a" => 1 }.fetch("a"))
rescue NoMethodError => e
  p e.message
end
p({ "a" => 1 }.respond_to?(:fetch))
p({ "a" => 1 }.respond_to?(:fetch, true))

# an untouched builtin method on the same reopened classes still dispatches
# normally
p [1, 2, 3].last
p({ "a" => 1 }.size)
