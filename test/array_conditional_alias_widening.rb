# A local assigned one of two Arrays (a ternary, if, case or ||) is an alias
# of each: a boxed value pushed through it widens the Arrays themselves, so
# the push lands in the chosen Array instead of in a converted copy.
def pick(x) = x
pick("s")

def ternary(gap)
  head = Array.new(0) { 0 }
  tail = Array.new(0) { 0 }
  tail << 1
  groups = gap ? tail : head
  groups << pick(2)
  [tail, head]
end

def if_arms(gap)
  head = Array.new(0) { 0 }
  tail = Array.new(0) { 0 }
  groups = if gap then tail else head end
  groups << pick(3)
  [tail, head]
end

def case_arms(n)
  head = Array.new(0) { 0 }
  tail = Array.new(0) { 0 }
  groups = case n when 1 then tail else head end
  groups << pick(4)
  [tail, head]
end

def or_arms(m)
  tail = Array.new(0) { 0 }
  groups = m || tail
  groups << pick(5)
  tail
end

def hash_arms(gap)
  head = Hash.new(0)
  tail = Hash.new(0)
  tail[1] = 1
  groups = gap ? tail : head
  groups[pick(2)] = pick(2)
  [tail, head]
end

def or_truthy_left
  head = Array.new(0) { 0 }
  tail = Array.new(0) { 0 }
  groups = head || tail
  groups << pick(6)
  [head, tail]
end

# more arms than the leaf buffer first holds
def many_arms(n)
  a0 = Array.new(0) { 0 }; a1 = Array.new(0) { 0 }; a2 = Array.new(0) { 0 }
  a3 = Array.new(0) { 0 }; a4 = Array.new(0) { 0 }; a5 = Array.new(0) { 0 }
  a6 = Array.new(0) { 0 }; a7 = Array.new(0) { 0 }; a8 = Array.new(0) { 0 }
  a9 = Array.new(0) { 0 }; b0 = Array.new(0) { 0 }; b1 = Array.new(0) { 0 }
  b2 = Array.new(0) { 0 }; b3 = Array.new(0) { 0 }; b4 = Array.new(0) { 0 }
  b5 = Array.new(0) { 0 }; b6 = Array.new(0) { 0 }
  groups = case n
           when 0 then a0 when 1 then a1 when 2 then a2 when 3 then a3
           when 4 then a4 when 5 then a5 when 6 then a6 when 7 then a7
           when 8 then a8 when 9 then a9 when 10 then b0 when 11 then b1
           when 12 then b2 when 13 then b3 when 14 then b4 when 15 then b5
           else b6
           end
  groups << pick(7)
  [a0, a5, b6]
end

p ternary(true)
p ternary(false)
p if_arms(true)
p if_arms(false)
p case_arms(1)
p case_arms(2)
p or_arms(nil)
p or_truthy_left
p many_arms(0)
p many_arms(5)
p many_arms(99)
p hash_arms(true)
p hash_arms(false)
