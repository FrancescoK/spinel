# spinel: gc-stress
# spinel: gc-minor
# spinel: share
# A local a block captures lives in a heap cell, and a store into the cell
# takes a write barrier. A store nested in the value of another such store
# took none: the barrier pass stepped over the whole outer statement. Once
# the cell was old, the young String stored into it was unrecorded, and the
# next collection freed it while the cell still held it. Each proc below
# stores into one captured local inside the value stored into another, then
# drops every other reference to what it stored; the loop allocates between
# calls and reads the inner local back.
def check(label, pr, n = 200)
  ok = 0
  n.times do |i|
    v = pr.call
    x = ["q" * 60, i]
    ok += 1 if v
  end
  puts "#{label}: #{ok}"
end

u = nil; t = nil
check("assign", proc { t = (u = "a" * 3).size.to_s; u == "aaa" })
u = +"x"
check("op-assign", proc { u = +"x"; t = (u += "y" * 2).size.to_s; u == "xyy" })
check("or-assign", proc { u = nil; t = (u ||= "z" * 2).size.to_s; u == "zz" })
c = false
check("ternary", proc { c = !c; t = (c ? (u = "k" * 2) : (u = "l" * 3)).size.to_s; u == "kk" || u == "lll" })
check("if", proc { t = (if c then u = "w" * 2 else "" end).size.to_s; !c || u == "ww" })
check("interpolation", proc { t = "#{(u = "f" * 2).size}"; u == "ff" })
w = nil
check("chained", proc { t = (w = (u = "j" * 3).size.to_s).size.to_s; u == "jjj" && w == "3" })
check("sequence", proc { t = (u = "r" * 2; u.size).to_s; u == "rr" })
check("and", proc { t = ((u = "s" * 2) && 7).to_s; u == "ss" })
check("while", proc { t = nil; t = (u = "v" * 2).size.to_s while t.nil?; u == "vv" })

# a bang's answer stored back into its receiver inside another local's value
s = [+"kl", 1].first
check("bang", proc { t = s.upcase!.size.to_s; s.downcase!; s == "kl" })
s = [+" ab ", 1].first
check("bang-assign", proc { t = (u = s.strip!).size.to_s; s = +" ab "; u == "ab" })

# in a method, and through a lambda
def in_method
  a = nil; b = nil
  check("method", proc { b = (a = "m" * 4).size.to_s; a == "mmmm" })
end
in_method
l = -> { t = (u = "o" * 2).size.to_s; u == "oo" }
check("lambda", l)
p u, t
