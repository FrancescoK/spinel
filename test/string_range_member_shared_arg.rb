# A String Range's membership (cover?, include?, member?, ===) with an
# argument held boxed (a method answering a String or an Integer) that is a
# String the program shares (changed in place through another name): the
# argument is a String, compared by its contents. Its handle was taken for
# another class, and the answer was false.
def pick(n, k)
  t = n.to_s + ""
  u = t
  u << ""
  k == 0 ? t : 1
end

a = 100
p((a.to_s.."102").cover?(pick(a + 1, 0)))
p((a.to_s.."102").include?(pick(a + 1, 0)))
p((a.to_s.."102").member?(pick(a + 1, 0)))
p((a.to_s.."102") === pick(a + 1, 0))
p((a.to_s.."102").cover?(pick(a + 9, 0)))
p((a.to_s.."102").cover?(pick(a + 1, 1)))
