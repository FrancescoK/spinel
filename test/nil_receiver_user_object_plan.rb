# A call on a user object that turns out to be nil raises NoMethodError, as
# CRuby does, after evaluating the arguments (#7444, step 3). The receiver's
# nil was decided in the analysis (the nil fact) and the call plan's nil
# target tests it: a local whose only write is conditional, a method's value
# through a case with no else, a reader-only class that kept a by-value
# layout before, a parameter some call hands nil, a global written nil, and
# an argument with a side effect, which runs before the raise.
class Box
  def initialize(v) = @v = v
  def v = @v
  def hello = "hi"
  def poke(x) = x + @v
end

def pick(n)
  case n
  when 1 then Box.new(1)
  end
end

def try
  yield
rescue NoMethodError => e
  puts e.message
end

def run(cond)
  b = Box.new(1) if cond
  try { p b.v }
  try { p pick(cond ? 1 : 2).hello }
  try { p pick(cond ? 1 : 2).v }
end
run(true)
run(false)

def arg
  puts "arg evaluated"
  1
end
w = pick(2)
try { p w.poke(arg) }

def take(b) = b.v
try { p take(Box.new(3)) }
try { p take(nil) }

$g = Box.new(4)
try { p $g.v }
$g = nil if ARGV.empty?
try { p $g.v }

# a guard narrows the read: no test, no raise
def guarded(b)
  return "none" unless b
  b.v
end
p guarded(nil), guarded(Box.new(5))
