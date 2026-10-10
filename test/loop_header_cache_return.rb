# A loop whose arrays keep their headers in C locals may hold a `return`
# (#8310): it only leaves the loop, and through an ensure it is a goto to
# the ensure, which runs outside the cached region.
def first_over(a, lim)
  i = 0
  while i < a.length
    return i if a[i] > lim
    i += 1
  end
  -1
end

def first_float(f, x)
  i = 0
  while i < f.size
    return f[i] * 2.0 if f[i] >= x
    i += 1
  end
  nil
end

def grows_in_ensure(a)
  begin
    i = 0
    while i < a.length
      return a[i] if a[i] == 3
      i += 1
    end
    0
  ensure
    100.times { |k| a << k }
    a[0] = 42
  end
end

a = [1, 5, 2, 9, 3]
p first_over(a, 4)
p first_over(a, 10)
p first_float([0.5, 1.5, 2.5], 1.0)
p first_float([0.5], 1.0)
b = [1, 2, 3, 4]
p grows_in_ensure(b)
p [b[0], b.length, b[103]]
