# A Hash subclass instance reaching the version entry of a method the
# subclass and the Hash reopening both define, defined in that order at run
# time: the entry's arm for Hash's version is a bare call to the reopening's
# method, which takes the instance boxed as the Hash it starts with.
class Hash
  def describe
    "hash of #{size}"
  end

  def reverse_merge(other)
    other.merge(self)
  end
end

class Hwia < Hash
end

def describe(h) = h.describe
def rm(h, o) = h.reverse_merge(o)

h = Hwia.new
h["a"] = 1
puts describe({})
puts describe(h)
p rm(h, { "b" => 2 })

class Hwia
  def describe
    "hwia, " + super
  end

  def reverse_merge(other)
    "hwia reverse_merge of #{other.size}"
  end
end

puts describe(h)
p rm(h, { "b" => 2 })
