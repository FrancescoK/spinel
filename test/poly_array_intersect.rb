# Array#intersect? through a poly receiver.
#
# The typed-receiver forms all resolved, so only a union receiver was missing
# an arm and the call raised NoMethodError naming Array -- which is what the
# receiver was. Every array kind coerces to a poly array, so one arm serves
# them all rather than one per element type.
# spinel: gc-stress
# spinel: gc-minor
def pick(flag)
  flag ? [1, 2] : "no"
end

p [1, 2].intersect?([2, 3])
p pick(true).intersect?([2, 3])
p pick(true).intersect?([7, 8])
p pick(true).intersect?([])

def pick_s(flag)
  flag ? ["a", "b"] : 0
end

p pick_s(true).intersect?(["b", "c"])
p pick_s(true).intersect?(["c"])

def pick_f(flag)
  flag ? [1.5, 2.5] : nil
end

p pick_f(true).intersect?([2.5])
p pick_f(true).intersect?([9.5])

def pick_sym(flag)
  flag ? [:a, :b] : 0
end

p pick_sym(true).intersect?([:b])
p pick_sym(true).intersect?([:z])

# a mixed array, and a poly argument
def pick_m(flag)
  flag ? [1, "a", :b] : 0
end

p pick_m(true).intersect?(["a"])
p pick_m(true).intersect?([:b])
p pick_m(true).intersect?([9])

def other(flag)
  flag ? [2] : "x"
end

p pick(true).intersect?(other(true))

# the shape it turned up in: a mapped receiver lands on the poly path
CONST = ["t2", "t9"]
rows = [["t1"], ["t2"]]
p rows.map { |r| r[0] }.intersect?(CONST)
p rows.map { |r| r[0] }.intersect?(["nope"])

# an empty receiver
def pick_e(flag)
  flag ? [1, 2].reject { |x| true } : "no"
end

p pick_e(true).intersect?([1])
