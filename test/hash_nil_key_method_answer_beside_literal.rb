# A method that fills an empty Hash local with `[]=`, keyed by an Integer that
# can be nil, and answers it beside a `{}` of its own: `(seen) || {}`, a
# conditional with a `{}` arm, a begin whose body names the local and whose
# else answers it. The method's return is then the box that joins the two, not
# the local's Hash, and the search for the method's answer took that to be a
# use that keeps the Hash typed: the nil key was refused at run time (a
# TypeError) where CRuby stores it. The local widens to the boxed-key kind
# alone, and a read that ends a begin's body beside an else (whose value the
# else replaces) hands nothing on.
def or_literal(a, k)
  seen = {}
  a.each_with_index { |x, i| seen[x] = i unless seen.key?(x) }
  (seen) || {}
end

def ternary_literal(a, k)
  seen = {}
  a.each_with_index { |x, i| seen[x] = i unless seen.key?(x) }
  k > 100 ? {} : seen
end

def begin_else(a, k)
  seen = {}
  a.each_with_index { |x, i| seen[x] = i unless seen.key?(x) }
  begin; k; seen; rescue; {}; else; seen; end
end

def begin_body_and_else(a, k)
  seen = {}
  a.each_with_index { |x, i| seen[x] = i unless seen.key?(x) }
  begin; seen; rescue; {}; else; seen; end
end

ints = [5, 6]
[ARGV.size + 7, ARGV.size].each do |i|
  b = ints[i]
  p or_literal([3, b, 3, b], 1)
  p ternary_literal([3, b, 3, b], 1)
  p begin_else([3, b, 3, b], 1)
  p begin_body_and_else([3, b, 3, b], 1)
end
