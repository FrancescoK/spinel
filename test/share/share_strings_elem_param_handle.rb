# Flag-only: a block parameter the rule holds as the shared handle, bound
# to the elements of a String Array -- a `map` folded over `scan`'s answer,
# `each_char` over a boxed String -- was declared as a plain String inside
# the loop while the body read it as the handle, and the C did not build.
# Each element is a fresh String the handle now wraps, bound into the
# parameter's own slot. (builtins/gem.rb's Gem::Version#initialize and
# tools/spin.rb's library_name? under `require "spin"` are these shapes.)
seen = []
def parts(v) = v.scan(/[0-9]+|[a-z]+/i).map { |s| s.match?(/\A\d+\z/) ? s.to_i : s }
x = parts("1.2rc3")
seen << x[2]
x[2] << "!"
p x, seen
# each_char over a boxed String whose block parameter the rule shares
def name_ok(s)
  s.each_char do |c|
    ok = (c >= "a" && c <= "z") || c == "_"
    return false unless ok
  end
  true
end
w = [+"abc", 1][0]
p name_ok(w), name_ok([+"a-b", 1][0])
q = [+"zz", 1][0]
q2 = q
q << "_y"
p q2, name_ok(q2)
