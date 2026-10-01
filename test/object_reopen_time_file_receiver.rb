# A program's own Object method called on a Time, a File or a Float range.
# The inference's arms for those receivers end in a catch-all -- Integer for
# Time, poly for File, unknown for a Float range -- that answered before the
# reopened-Object fallback, while the emitter calls the Object method on the
# boxed receiver: `(Time.at(100) - 100).me == Time.at(0)` was refused, and
# `p((Time.at(100) - 100).me.to_i)` read a boxed value into an int slot.

class Object
  def me = self
  def tag = "t#{1 + 1}"
  def pair(n) = [self, n * 2]
end

p((Time.at(100) - 100).me == Time.at(0))
p((Time.at(100) - 100).me.to_i)
p((Time.at(100) + 100).me.to_i)
x = Time.at(100) - 100
p x.me.to_i
p Time.at(5).tag
p Time.at(5).tag.size
p Time.at(5).pair(3)[1]
p Time.at(5).me.class
p Time.at(5).year == Time.at(5).me.year
p((Time.at(100) - Time.at(50)).me)

f = File.open(__FILE__)
p f.tag
p f.me.class
p f.me.path == __FILE__
f.close

r = 1.0..2.5
p r.tag
p r.me.class
p r.me.last
