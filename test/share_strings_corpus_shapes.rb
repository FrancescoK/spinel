# Shapes the corpus reached only under --share-strings: a String written
# through an attribute writer into a slot that is the shared handle, ENV's
# own mutators, Regexp.union of a shared String, and a poly Array of
# handles stored into a typed String Array slot.
class Box
  attr_accessor :name, :list
end
b = Box.new
b.name ||= "anon"
b.name += "?"
b.name &&= b.name + "!"
p b.name
def fresh = ["made"]
Box.new.list = %w[seed]
c = Box.new
c.list ||= fresh
p c.list
ENV["SPX_SHARE"] = +"v"
saved = ENV.to_hash
ENV.replace(saved)
p ENV["SPX_SHARE"]
s = +"h."
s << "k"
s = 2 if ARGV.size > 5
p Regexp.union(s, "c"), Regexp.union(["c", s])
