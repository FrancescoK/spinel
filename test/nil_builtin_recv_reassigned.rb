# A builtin called on a String, Array or Hash that may be nil reads its
# receiver before its arguments, as CRuby does, even when an argument
# reassigns the variable it is read from. The nil test ran after the
# arguments and read what they left there: `s.split((s = "q,r"; ","))`
# split the new String rather than raising for nil, or splitting the old
# one. Through a proc that assigns the local, and through a global, too.

def show(tag)
  r = yield
  puts "#{tag} #{r.inspect}"
rescue => e
  puts "#{tag} #{e.class}: #{e.message}"
end

def locals(k)
  s = k == 0 ? nil : +"a,b"
  show("split") { s.split((s = +"q,r"; ",")) }
  show("after") { s }
  a = k == 0 ? nil : [1, 2]
  show("push") { a.push((a = [9]; 3)) }
  show("after") { a }
  h = k == 0 ? nil : { 1 => 2 }
  show("fetch") { h.fetch((h = { 3 => 4 }; 1)) }
  t = k == 0 ? nil : +"x"
  set = ->(v) { t = v }
  show("proc") { t.center((set.(+"long"); 5)) }
  show("after") { t }
end

def mutators(k)
  s = k == 0 ? nil : +"ab"
  u = s
  show("append") { s << (s = +"x"; "y") }
  show("after") { [s, u] }
end

def globals(k)
  $g = k == 0 ? nil : +"a,b"
  show("global") { $g.split(($g = +"q,r"; ",")) }
  show("after") { $g }
end

locals(ARGV.size)
locals(ARGV.size + 1)
mutators(ARGV.size)
mutators(ARGV.size + 1)
globals(ARGV.size)
globals(ARGV.size + 1)
