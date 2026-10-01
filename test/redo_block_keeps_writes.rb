# `redo` re-runs a block's body without binding its parameters again or
# starting its locals over. A parameter the body assigns is rebound from a
# renamed one at the top of the body, and the locals are reset there; the
# redo label sat above both, so a redo put the parameter back to the
# yielded value and a local back to nil (a loop that counted in a local
# never ended).
d = false
[1].each { |x| unless d; d = true; x = 5; redo; end; p x }

f = false
3.times { |i| unless f; f = true; i = 9; redo; end; p i }

def yy = yield(4)
g = false
yy { |x| unless g; g = true; x = 8; redo; end; p x }

# the value flows on as the block's value through a yield
def yv = yield(2)
h = false
p(yv { |x| unless h; h = true; x = 20; redo; end; x + 1 })

# a parameter set to nil, then read
def t(xv, z)
  rr = false
  [xv].each do |x|
    if x
      p x
      unless rr
        rr = true
        x = z
        redo
      end
    end
    p [:after, x]
  end
end
t(1, 5)
t(1, nil)

[1].each { |x| y = y.to_i + 1; redo if y < 3; p y }
[5].each { |x| c = (c || 0) + 1; redo if c < 4; p [x, c] }

# blocks whose value is collected: map, select, reject, then, find,
# flat_map, a count, a Hash's map, an Enumerator's map
r1 = false; p([1, 2].map { |x| unless r1; r1 = true; x = 7; redo; end; x * 10 })
r2 = false; p([1, 2, 3].select { |x| unless r2; r2 = true; x = 5; redo; end; x > 2 })
r3 = false; p([1, 2, 3].reject { |x| unless r3; r3 = true; x = 5; redo; end; x > 2 })
r4 = false; p(3.then { |x| unless r4; r4 = true; x = 4; redo; end; x + 1 })
r5 = false; p([1, 2].find { |x| unless r5; r5 = true; x = 9; redo; end; x > 5 })
r6 = false; p([1, 2].flat_map { |x| unless r6; r6 = true; x = 9; redo; end; [x] })
r7 = false; p([1, 2].count { |x| unless r7; r7 = true; x = 9; redo; end; x > 5 })
r8 = false; p({ a: 1 }.map { |k, v| unless r8; r8 = true; v = 9; redo; end; [k, v] })
r9 = false; p(3.times.map { |x| unless r9; r9 = true; x = 9; redo; end; x })
r10 = false; p(["a"].map { |s| unless r10; r10 = true; s = "z"; redo; end; s * 2 })
t = 0
p([1, 2].map { |x| t += 1; redo if t < 3; x })

# inside a loop that has a redo of its own, the block's redo is still the
# block's
i = 0
d2 = false
while i < 2
  i += 1
  p([i].map { |x| unless d2; d2 = true; redo; end; x * 10 })
  redo if i > 5
end

# a body with rescue: the label goes on the body itself
k = 0
[1].each do |x|
  k += 1
  redo if k < 3
  p [x, k]
rescue
  p :never
end
