# spinel: share
# spinel: gc-minor
# A method answers an Array of shared Strings or nil, and the caller appends
# a new String (`+"x"`) to it: the new String is run before the nil test, as
# CRuby runs an argument before the call raises, and the Array takes it as a
# String of its own. Every way a method answers the Array or nil, every
# append, and a local, a parameter, an instance variable and a value are
# tried.
def tern(f)
  t = +"t"
  a = [t]
  t << "!"
  f ? a : nil
end

def cond(f)
  t = +"t"
  a = [t]
  t << "!"
  if f
    a
  else
    nil
  end
end

def kase(f)
  t = +"t"
  a = [t]
  t << "!"
  case f
  when true then a
  else nil
  end
end

def andor(f)
  t = +"t"
  a = [t]
  t << "!"
  g = f ? 1 : nil
  g && a
end

def guard(f)
  t = +"t"
  a = [t]
  t << "!"
  return nil unless f
  a
end

def bare(f)
  t = +"t"
  a = [t]
  t << "!"
  return unless f
  a
end

def orelse(f)
  t = +"t"
  a = [t]
  t << "!"
  x = f ? a : nil
  x || nil
end

def try_push(label)
  yield
rescue NoMethodError
  puts "nme #{label}"
end

# each way of answering the Array or nil, appended to
%i[tern cond kase andor guard bare orelse].each do |m|
  r = send(m, true)
  r << +"x"
  n = send(m, false)
  p r, n
  try_push(m) { n << +"y" }
end

# each append on the Array and on the nil
def appends(f)
  r = tern(f)
  r.push(+"p")
  r.concat([+"c"])
  r.insert(1, +"i")
  r.unshift(+"u")
  r[0] = +"z"
  r[r.size] = +"s"
  r
end
p appends(true)
%w[push concat insert unshift aset].each_with_index do |name, i|
  n = tern(false)
  try_push(name) do
    case i
    when 0 then n.push(+"p")
    when 1 then n.concat([+"c"])
    when 2 then n.insert(1, +"i")
    when 3 then n.unshift(+"u")
    else n[0] = +"z"
    end
  end
end

# a parameter
def add(x)
  x << +"a"
end
r = tern(true)
add(r)
p r
try_push("param") { add(tern(false)) }

# an instance variable
class K
  def initialize(f)
    @r = tern(f)
  end

  def add
    @r << +"i"
    @r.push(+"j", +"k")
  end

  def r
    @r
  end
end
k = K.new(true)
k.add
p k.r

# the value of the append, and two Strings pushed at once
r = tern(true)
v = (r << +"x")
p v, v.equal?(r)
p r.push(+"y", +"z")
try_push("value") { p(tern(false).push(+"y", +"z")) }

# a String that is the end of a Range, one an append on a new String answers
# and one made after an effect, each run before the nil test
def mix(f)
  t = +"t"
  a = [t, 1]
  t << "!"
  f ? a : nil
end

def span(s) = (s.."ad")

log = []
r = mix(true)
r << span("ab").first
r << (+"y" << +"z")
r << (log << 1; +"w")
n = mix(false)
p r, n, log
try_push("range") { n << span("ab").last }
try_push("append") { n << (+"y" << +"z") }
try_push("effect") { n << (log << 2; +"w") }
p log

# the appended Strings are the Array's own: a change through an element shows
# in the Array
r = tern(true)
r << +"q"
r[1] << "?"
r[0] << "."
p r
