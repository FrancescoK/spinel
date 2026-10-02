# A String yielded to a block whose parameter a lambda or proc inside
# captures and appends to goes over as a copy. Where nothing can tell -- the
# variable is never read again, or only before, to print it -- the program
# compiles and answers as CRuby does; where something can, it is refused
# (test/reject/string_yield_captured_*).
def y1(v) = yield(v)
u1 = +"a"
y1(u1) { |q| l = lambda { q << "#"; p q }; l.() }

def y2(*a) = yield(*a)
u2 = +"c"
y2(u2) { |q| l = -> { q << "#"; p q }; l.() }

def y3
  s = +"m"
  p s
  yield s
end
y3 { |q| pr = proc { q.concat("!"); p q }; pr.call }

# a block parameter that only reads, and a literal, are not refused
u4 = +"d"
y1(u4) { |q| g = -> { q + "x" }; p g.call }
p u4
y1(+"lit") { |q| l = -> { q << "x"; p q }; l.() }

# as before: an Array element, and the append made directly, are shared
u5 = +"e"
[u5].each { |q| h = -> { q << "%" }; h.call }
p u5
u6 = +"f"
y1(u6) { |q| q << "&" }
p u6

# Rebinding or assigning the result back preserves the program's answer.
r2 = +"old"
y1(r2) { |q| l = -> { q << "!" }; l.call }
r2 = +"new"
p r2
r3 = +"a"
r3 = y1(r3) { |q| l = -> { q << "!" }; l.call }
p r3

# A frozen variable still raises, and its rescue can read the variable.
r4 = "frozen"
begin
  y1(r4) { |q| l = -> { q << "!" }; l.call }
rescue FrozenError
  p r4
end

# Replacing a formal before yielding severs its link to the caller.
def y4(v)
  v = +"own"
  yield v
end
r5 = +"caller"
y4(r5) { |q| l = -> { q << "!"; p q }; l.call }
p r5

# The frozen-variable exception also applies to a global.
$frozen = "global"
begin
  y1($frozen) { |q| l = -> { q << "!" }; l.call }
rescue FrozenError
  p $frozen
end

# Target writes with no later observer still permit a copy.
yield_target = "lit"
yield_target, = [String.new("target")]
y1(yield_target) { |q| l = -> { q << "#"; puts q }; l.call }

# Each method or lambda call starts with a fresh local.
def fresh_yield
  s = String.new("fresh")
  puts s
  y1(s) { |q| l = -> { q << "#"; puts q }; l.call }
end
fresh_yield
fresh_yield
fresh_lambda_yield = -> {
  yield_lambda_local = String.new("lambda")
  puts yield_lambda_local
  y1(yield_lambda_local) { |q| l = -> { q << "#"; puts q }; l.call }
}
fresh_lambda_yield.call
fresh_lambda_yield.call

# Discarded aliases and scalar query results keep no second name.
yield_discard = String.new("discard")
yield_discard.itself
p(yield_discard)
puts yield_discard.length
puts yield_discard.size
puts yield_discard.bytesize
p yield_discard.empty?
p yield_discard.frozen?
p puts(yield_discard)
p print(yield_discard)
y1(yield_discard) { |q| l = -> { q << "#"; puts q }; l.call }
