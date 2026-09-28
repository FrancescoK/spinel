# A parameter default that assigns a local the body reads -- the
# `default = (no_default = true)` idiom of activesupport's
# Enumerable#index_with, which tells "omitted" from "passed" by the local the
# default leaves behind (nil when the argument was passed). Defaults are
# evaluated at the call site, so the local is bound in the callee instead: the
# parameter takes a private sentinel and the callee runs the default itself
# when it sees it.

def index_with(items, default = (no_default = true))
  if block_given?
    items.to_h { |e| [e, yield(e)] }
  elsif no_default
    "no default"
  else
    items.to_h { |e| [e, default] }
  end
end
p index_with([1, 2]) { |e| e * 10 }
p index_with([1, 2])
p index_with([1, 2], 0)
p index_with([1, 2], nil)

# the local is nil when the argument was passed, even to the default's own value
def tally(n = (omitted = true; 3))
  [n, omitted]
end
p tally
p tally(7)
p tally(3)

# a keyword parameter, and a default with several statements
def greet(name, greeting: (custom = false; "hello"))
  "#{greeting} #{name} (custom: #{custom.inspect})"
end
puts greet("ann")
puts greet("bob", greeting: "hi")

# a caller that spreads its arguments
args = [[3, 4]]
p index_with(*args)
args = [[3, 4], 9]
p index_with(*args)

# the shape docs/limitations.md used to list: a default reading an earlier
# parameter, its local read by the body, called directly and bound
def m(a, c = (z = a + 1; z))
  [c, z]
end
p m(1)
p m(1, 5)
p method(:m).call(2)
p method(:m).to_proc.call(2, 9)
