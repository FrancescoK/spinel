# Methods of modules that class bodies extend, which send by name and so
# generate code, and that nothing expands: a call they can take keeps each.
# `mk(...)` takes any number of arguments, and `T.hits += 1` calls the reader
# `hits` with none and the writer `hits=` with one.
module Fwd
  def mk(...) = public_send(:fwd, ...)
  def fwd(a, b) = a + b
end
class T
  extend Fwd
end
p T.mk(1, 2)

module Counter
  def hits = public_send(:base)
  def base = 5
  def hits=(v)
    @h = v
  end
  def h = @h
end
class U
  extend Counter
end
U.hits += 1
p U.h
class V
  extend Counter
end
V.hits ||= 9
p V.h
