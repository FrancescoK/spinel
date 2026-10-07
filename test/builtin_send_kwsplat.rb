def ev(object, method, *args, **) = object.send(method, *args, **)
def pub(object, method, *args, **kw) = object.public_send(method, *args, **kw)
def plain(object, method, *args) = object.send(method, *args)

m = "abc".match(/b/)
p ev(m, :end, 0)
p ev(m, :begin, 0)
p pub(m, :end, 0)

p ev("hello", :upcase)
p ev("hello", :index, "l")
p pub("hello", :center, 9, "*")

p ev([1, 2, 3], :first)
p ev([1, 2, 3], :include?, 2)
p ev([3, 1], :sum, 0)
p pub([1, 2, 3], :first, 2)

p ev(5, :+, 3)
p ev(10, :digits)
p ev(10, :pow, 2)
p ev([{a: 1}], :include?, a: 1)
p ev("ab", :%, 1)

p ev(2.5, :round)
p ev(2.5, :round, half: :even)
p pub(25, :round, -1, half: :even)

p plain("ab\n", :chomp)
p plain("a\nb\n", :lines)
p plain("hello", :index, "l", 1)

def fwd(a, *r, **) = a.index(*r, **)
p fwd("hello", "l")

h = {a: 1}
begin
  p ev([1, 2, 3], :first, **h)
rescue TypeError => e
  p e.class
end
