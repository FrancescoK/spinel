# A String's `[]=` (every form) and `insert` evaluate the index and the
# value before they read the String: CRuby runs the arguments, then checks,
# measures and cuts the String. The C read the String in operands whose order
# C does not fix, around a value that ran in the middle, so a value that
# changes the String (in the same expression, through a method, a block or
# another name for it) answered the unchanged String or lost the change, and
# the cut pieces sat unrooted while the next one allocated, which a
# collection at every allocation turned into a freed string read back. A
# value that is not a String raises TypeError before the index is checked.
# Each local lives in its own method, and the blocks change an instance
# variable's String: a block that reads the receiver local itself is a
# separate shape.
# spinel: gc-stress
def grow(s)
  s << "xyz"
  "G"
end

def shrink(s)
  s.slice!(4)
  "J"
end

# v shortens the String in the same expression
def inline_shrink
  s = +"hello"
  s[0] = (s.setbyte(1, 69); s.slice!(4); "J")
  puts s
end

# v appends to the String, and the index counts from the end
def inline_grow_negative
  s = +"abcdef"
  s[-2] = (s << "!!"; "Z")
  puts s
end

# v is a method call that changes the String
def call_shrink
  s = +"hello"
  s[0] = shrink(s)
  puts s
end

def call_grow
  s = +"abcde"
  s[2] = grow(s)
  puts s
  s = +"abcde"
  s[-1] = grow(s)
  puts s
end

# v changes an instance variable's String in the same expression
class Holder
  def initialize
    @s = +"hello"
  end

  def run
    @s[1] = (@s << "x"; "E")
    puts @s
    @s[-1] = (@s.slice!(0, 2); "!")
    puts @s
  end
end

# v is a block that changes an instance variable's String
class BlockHolder
  def initialize
    @s = +"abcde"
  end

  def run
    @s[1] = [1, 2].map { |i| @s << i.to_s; "B" }.first
    puts @s
    @s = +"abcde"
    @s[3] = 3.times.map { |i| @s.upcase!; "d" }.last
    puts @s
  end
end

# v allocates, so the collector may run while the pieces are live
def allocating
  s = +"abcdef"
  s[1] = Array.new(200) { |i| (i * 7).to_s }.join[0, 3]
  puts s
  s = +"abcdef"
  s[-1] = "#{"p" * 40}#{s.size}".sub(/p+/, "Q")
  puts s
  s = +"0123456789"
  100.times { |i| s[i % 10] = ((i * 7) % 10).to_s }
  puts s
end

# a literal and a plain read, the paths that are unchanged
def plain
  s = +"hello"
  s[0] = "J"
  puts s
  s[-1] = "y"
  puts s
  u = +"ab"
  s[2] = u
  puts s
  s[5] = "!"
  puts s
end

# the index error still comes after v ran
def index_error
  s = +"abc"
  begin
    s[9] = (s << "d"; "x")
  rescue IndexError => e
    puts "#{e.class}: #{e.message}"
  end
  puts s
end

# every other form, with a value that grows or shrinks the String
def forms
  s = +"abcdef"
  s[1..2] = (s << "XY"; "r")
  puts s
  s = +"abcdef"
  s[-3..-2] = (s << "XY"; "r")
  puts s
  s = +"abcdef"
  s[1, 2] = (s << "XY"; "t")
  puts s
  s = +"abcdef"
  s[1, 2] = (s.slice!(0); "t")
  puts s
  s = +"abcdef"
  s["cd"] = (s.slice!(0); "S")
  puts s
  s = +"abcdef"
  s[/cd/] = (s.slice!(0); "R")
  puts s
  s = +"abcdef"
  s[/(c)(d)/, 1] = (s.slice!(0); "C")
  puts s
  s = +"abcdef"
  s.insert(2, (s << "XY"; "I"))
  puts s
  s = +"abcdef"
  s.insert(-2, (s << "XY"; "I"))
  puts s
  s = +"abcdef"
  r = s.insert(-2, (s << "XY"; "I"))
  puts r
  s = +"abc"
  s[(s << "d"; -1)] = "Z"
  puts s
end

# the value changes the String through another name for it
def alias_value
  s = +"abcdef"
  u = s
  s[1] = (u << "Q"; "y")
  puts s
  s[1..2] = (u.slice!(0); "r")
  puts s
  s["e"] = (u << "W"; "E")
  puts s
  s.insert(-1, (u << "Z"; "!"))
  puts s
  r = s.insert(0, (u.slice!(0); "<"))
  puts r, u
end

def changer(t)
  t << "+"
  "m"
end

def alias_method_value
  s = +"abc"
  u = s
  s[0] = changer(u)
  s[/c/] = changer(u)
  puts s, u
end

# with an alias the String is changed through the in-place shim: a block,
# another String's change and a call given the String itself in the
# argument run before the shim copies the String
def alias_argument_shapes
  s = +"abcdef"
  u = s
  s[1] = [1, 2].map { |i| s[i] }.join
  p s, u
  t = +"xy"
  w = t
  s[0] = (t[0] = s.slice!(0))
  p s, u, t, w
  s[0] = changer(s)
  p s, u
end

# slice! on the String a chain of insert / << / concat / prepend / replace
# hands back cuts that String, after the chain ran; on a String no other
# name holds it answers the part it cuts. A `[]=` value of that shape on an
# aliased String runs before the shim copies the String.
def slice_on_chains
  s = +"abcdef"
  p s.insert(0, "<").slice!(0, 2), s
  p s.insert(1, "Q").insert(0, "R").slice!(1, 3), s
  p (s << "xy").slice!(-2, 2), s
  p s.concat("12", "34").slice!(-4, 9), s
  p s.prepend("P").slice!(0), s
  p s.replace("hello").slice!(1..2), s
  p s.insert(0, "<").slice!(9, 1), s.insert(0, "<").slice!(-20, 1), s
  r = s.insert(0, (s << "!"; "A")).slice!(0, 2)
  p r, s
  t = +"abc"
  p (+"hello").slice!(1, 2), "#{t}def".slice!(2, 3), (t + "xyz").slice!(-3, 2)
  p (t * 3).slice!(3, 3), t.dup.slice!(0, 2), t.upcase.slice!(1, 5), t
  p "#{t}".slice!(5, 1), "#{t}".slice!(3, 1), "#{t}".slice!(1, -1)
  u = s
  s[1] = s.insert(0, "<").slice!(0, 2)
  p s, u
end

# insert converts a boxed value (a fiber's) to the String it inserts
def boxed_insert
  s = +"abcdef"
  s.insert(0, Fiber.new { s[1] }.resume)
  s.insert(-1, Thread.new { "T" }.value)
  p s
end

# the value's TypeError and the index errors
def errors
  s = +"abc"
  begin
    s[9] = 5
  rescue TypeError => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    s.insert(9, "x")
  rescue IndexError => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    s.insert(-5, "x")
  rescue IndexError => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    r = s.insert(-5, "x")
  rescue IndexError => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    s["zz"] = (s << "!"; "x")
  rescue IndexError => e
    puts "#{e.class}: #{e.message}"
  end
  puts s
  f = "lit"
  begin
    f[0] = (puts "value first"; "x")
  rescue FrozenError => e
    puts e.class
  end
end

# a boxed value: the substring and Regexp-group forms say "not matched"
# before they convert it
def boxed_late
  s = +"abc!"
  pick = [1, "q"]
  begin
    s["zz"] = pick[s.size - 4]
  rescue IndexError => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    s[/(z)/, 1] = pick[s.size - 4]
  rescue IndexError => e
    puts "#{e.class}: #{e.message}"
  end
  s["b"] = pick[s.size - 3]
  s[/(c)/, 1] = pick[s.size - 3]
  puts s
end

# every form under allocation, so a collection at every allocation finds
# each piece rooted; slice! cuts its String the same way
def pressure
  s = +"0123456789"
  u = s
  40.times do |i|
    k = i % 10
    s[k] = (i * 3 % 10).to_s
    s[k..k] = [i.to_s].join[-1]
    s[k, 1] = "#{i % 7}"
    s[s[k]] = "#{i % 5}"
    s[/\d/] = (i % 9).to_s
    s[/(\d)(\d)/, 2] = (i % 4).to_s
    s.insert(k, (i % 6).to_s)
    s[k + 1, 1] = ""
    s.insert(k, "ab")
    s.slice!(k)
    s.slice!(k, 1)
    r = s.slice!(k)
    s << r
    r = s.slice!(k, 1)
    s << r
  end
  puts s, u
end

inline_shrink
inline_grow_negative
call_shrink
call_grow
Holder.new.run
BlockHolder.new.run
allocating
plain
index_error
forms
alias_value
alias_method_value
alias_argument_shapes
slice_on_chains
boxed_insert
errors
boxed_late
pressure
