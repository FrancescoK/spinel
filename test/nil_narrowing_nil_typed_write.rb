# The nil narrowing counts a write of a value the marks call non-nil as a
# fact. A value typed nil -- a parameter only ever passed nil, a local only
# nil is written to -- carries no mark, since it is no Integer that may be
# nil; written to an Integer or Float local it is still a nil.

# Written straight after a guard, to a local already nilable elsewhere.
def param_write(z, k)
  x = 5
  x = nil if k == 9
  if x
    x = z
    p x
    puts(x > 0)
  end
rescue NoMethodError
  puts "NoMethodError"
end
param_write(nil, 1)

def local_write(k)
  x = 5
  x = nil if k == 9
  if x
    nl = nil
    x = nl
    puts(x.is_a?(Integer))
    puts(x < 9)
  end
rescue NoMethodError
  puts "NoMethodError"
end
local_write(1)

# Written by a closure the fact survived the call of: the write was not
# among those that can leave the local nil.
def closure_write(z)
  x = 5
  x = nil if z == 9
  pr = proc { x = z }
  if x
    pr.call
    puts(x >= 1)
  end
rescue NoMethodError
  puts "NoMethodError"
end
closure_write(nil)

# A Float, and a value the marks do know is non-nil, which stays narrowed.
def float_write(z, k)
  x = 1.5
  x = nil if k == 9
  if x
    x = z
    puts(x <=> 0.5)
    x = 2.5
    puts(x > 1)
  end
end
float_write(nil, 1)
