# `Array.prepend(M)` and `String.include(M)` as statements are the
# reopenings they amount to: a prepended method answers in the builtin's
# place, and an included one answers a name the class does not define
module Rev
  def shuffle = [:prepended]
end
Array.prepend(Rev)
p [1, 2].shuffle
module Sz
  def shout = self.upcase + "!"
end
String.include(Sz)
p "abc".shout
module Twice
  def twice = self * 2
end
Integer.include(Twice)
p 21.twice
module R
  def shuffle = [:included]
end
Hash.include(R)
p({ a: 1 }.shuffle)
