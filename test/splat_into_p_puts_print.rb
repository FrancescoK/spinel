# `p(*v)`, `puts(*v)` and `print(*v)` as statements: a splatted value that is
# no Array is the one argument, a Range or an Enumerator its members, nil
# none. Only an Array was spread; anything else printed nothing.
w = 5
p(*w)
puts(*w)
print(*w, "\n")
s = "t"
p(*s)
puts(*s)
r = 3..4
p(*r)
puts(*r)
print(*r, "\n")
q = ("a".."b")
p(*q)
f = 1.5
p(*f)
y = :sym
p(*y)
n = nil
p(*n)
puts(*n)
print(*n)
e = [6, 7].each
p(*e)
puts(*e)
a = [1, 2]
p(*a)
puts(*a)
print(*a, "\n")

# beside other arguments
p(0, *w)
p(*w, 9)
p(0, *r, 9)
puts(0, *r)
print(0, *r, "\n")
p(*a, *r, *n, *w)

# a value whose kind is known only at run time
def show(v)
  p(*v)
  puts(*v)
  print(*v)
  puts "-"
end
show([8, 9])
show(5)
show("t")
show(nil)
show(3..4)
show("a".."b")
show([])
show([1, 2].each_slice(1))
def pairs(v)
  p(*v)
  puts "-"
end
pairs({ k: 1 })

# every argument is read before anything is written
def spill(v)
  i = 0
  p(*v, i += 1)
  puts(*v, i += 1)
  print(*v, i += 1, "\n")
end
spill(5)
spill(3..4)
spill(nil)
spill([8])
