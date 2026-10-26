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

p ternary(true)
p ternary(false)
p if_arms(true)
p if_arms(false)
p case_arms(1)
p case_arms(2)
p or_arms(nil)
p hash_arms(true)
p hash_arms(false)
