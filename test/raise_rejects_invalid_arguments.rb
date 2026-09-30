# raise takes a message String alone, an exception class or object with an
# optional message, and `cause:` an exception or nil; anything else is a TypeError.
def tried
  yield
  :no_raise
rescue TypeError, RuntimeError, ArgumentError => e
  [e.class, e.message, e.cause.class]
end

p tried { raise "x" }
p tried { raise "x", "y" }
p tried { raise "x", nil }
p tried { raise "x", 1 }
p tried { raise "x", RuntimeError }
p tried { raise "x", :sym }
p tried { raise "x", "y", "z" }
p tried { raise RuntimeError, "x" }
p tried { raise RuntimeError, nil }
p tried { raise RuntimeError.new("o") }
p tried { raise ArgumentError }

s = "m"
q = "q"
p tried { raise s, q }
log = []
p tried { raise((log << :first; "a"), (log << :second; "b")) }
p log

# cause: an exception or nil
base = RuntimeError.new("base")
p tried { raise "x", cause: base }
p tried { raise "x", cause: nil }
p tried { raise "x", cause: false }
p tried { raise "x", cause: true }
p tried { raise "x", cause: 1 }
p tried { raise "x", cause: "s" }
p tried { raise "x", cause: :sym }
p tried { raise "x", cause: [base] }
p tried { raise RuntimeError, "x", cause: base }
p tried { raise RuntimeError, "x", cause: 5 }
p tried { raise ArgumentError, cause: false }
p tried { raise RuntimeError.new("o"), cause: "c" }

c = 3
p tried { raise "x", cause: c }
log = []
p tried { raise "x", cause: (log << :cause; false) }
p log

# a cause from a rescue variable keeps working
begin
  begin
    raise "inner"
  rescue => e
    raise "outer", cause: e
  end
rescue => outer
  p [outer.message, outer.cause.message]
end

# a cause that is not an exception: the message String runs, then the cause, then the TypeError
p tried { raise "x", cause: 1.5 }
p tried { raise "x", cause: RuntimeError }
p tried { raise "x", cause: (1..2) }
log = []
p tried { raise((log << :first; "a"), cause: (log << :cause; :c)) }
p log
log = []
p tried { raise "x", cause: [1, 2].map { |v| log << v; v } }
p log

# only a String that stands alone checks its cause; a wrong first argument is the first error
p tried { raise 1, cause: false }
p tried { raise nil, cause: false }
p tried { raise Object.new, cause: "c" }

# an empty splat or keywords after a String add no second argument
none = []
opts = {}
p tried { raise "x", *none }
p tried { raise "x", **opts }
p tried { raise "x", *none, cause: base }
def fwd(m, **o) = raise(m, **o)
p tried { fwd("x") }
def fwd2(m, *r) = raise(m, *r)
p tried { fwd2("x") }

# a cause that holds nil at run time is no cause; one that holds a String is a TypeError
h = { "a" => "b" }
p tried { raise "x", cause: h["z"] }
p tried { raise "x", cause: h["a"] }
ns = ["s"]
p tried { raise "x", cause: ns[3] }
p tried { raise "x", cause: ns[0] }
p tried { raise "x", cause: ENV["NO_SUCH_VARIABLE_SET_FOR_THIS_TEST"] }

# operands that hoist statements run once
log = []
p tried { raise [1, 2].map { |v| log << v; v.to_s }.join, cause: false }
p log
log = []
p tried { raise RuntimeError, [3, 4].map { |v| log << v; v.to_s }.join, cause: 5 }
p log
log = []
p tried { raise [5].map { |v| log << v; v.to_s }.join, cause: h["z"] }
p log

# a first argument typed as an exception that holds nil at run time is the first error
nilexc = nil
nilexc = RuntimeError.new("x") if ARGV.size > 5
p tried { raise nilexc, "d", cause: false }
p tried { raise nilexc, cause: 1.5 }
p tried { raise $!, "d", cause: false }
log = []
p tried { raise nilexc, (log << :msg; "d"), cause: (log << :cause; false) }
p log

# an empty Array or Hash literal is no exception
p tried { raise "x", cause: [] }
p tried { raise "x", cause: {} }
