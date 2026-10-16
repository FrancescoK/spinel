# x.match?(re) on a boxed value that may be a Class: a module answering
# match? itself (with another arity) gets its own arm, and any other class
# value has no match? -- String#match? is not run on the class
module M
  def match?(value, matcher) = value == matcher
  module_function :match?
end

class P
  def match?(re) = true
end

def check(x) = x.match?(/ab/)

p check("xab")
p check("zz")
p check(P.new)
begin
  check(M)
rescue ArgumentError => e
  p e.class
end
begin
  check(Integer)
rescue NoMethodError => e
  p e.class
end
p M.match?(1, 1)
