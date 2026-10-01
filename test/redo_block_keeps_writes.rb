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

# a body with rescue: the label goes on the body itself
k = 0
[1].each do |x|
  k += 1
  redo if k < 3
  p [x, k]
rescue
  p :never
end
