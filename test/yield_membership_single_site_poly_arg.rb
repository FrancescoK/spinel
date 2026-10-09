# A single yield call site whose receiver is always a concrete kind (a
# literal String block, one call site only) answers that kind's builtin,
# even when the ARGUMENT is boxed and some unrelated class reopens the
# same membership method name. The widening that makes `yield.include?`
# poly when sites disagree (yield_reopen_builtin_poly_arg.rb) is about
# receiver ambiguity across sites; a lone site's receiver kind is not
# ambiguous just because the call's argument is boxed and Array happens
# to reopen include? elsewhere. The String site's native Boolean must
# not land in a poly slot unboxed.
class Array
  def include?(x) = "reopened-array"
end

def inc(v) = yield.include?(v)
mixed = [1, "a"]
arg = mixed[1]
p inc(arg) { "abcxdef" }

class Range
  def member?(x) = "reopened-range"
end

def mem(v) = yield.member?(v)
p mem(arg) { {"a" => 1} }
