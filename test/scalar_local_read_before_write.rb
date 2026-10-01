# A local reads nil until a write runs. An Integer or Float local whose
# writes ahead of a read are all conditional -- a modifier `if`, one branch
# of an `if`, a loop body, a multiple assignment under `if false`, a body a
# rescue left early -- started at 0 or 0.0, and the read answered that.
def t
  nl = nil
  mk, x = 0, nl if false
  p mk
  v = 1 if false
  p v, v.nil?, v.to_s
  w = 2.5 if false
  p w
  i = 0
  while i < 2
    k = i * 10
    i += 1
  end
  p k
  j = 5
  while j < 3
    n = j
    j += 1
  end
  p n
  begin
    u = Integer("x")
  rescue ArgumentError
  end
  p u
end
t

def both(c)
  if c
    x = 1
  else
    x = 2
  end
  case c
  when true then y = 3
  else y = 4
  end
  q = (r = 5) + 1
  p [x, y, r, q]
end
both(true)
both(false)

f = 1.5 if ARGV.size > 3
p f
a, b = 1, 2 if ARGV.empty?
p a, b
