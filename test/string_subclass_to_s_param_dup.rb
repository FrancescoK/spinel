# spinel: share
# String#to_s of a String subclass is a new String, also when the
# result goes back into a parameter that takes other values too.
class Sub < String
end
class Named < String
  def to_s
    "named:" + self
  end
end
def copy(str)
  str = str.to_s
  str.dup
end
def same(str)
  str = str.to_s
  str
end
p copy(Sub.new("a")).class
p copy("b").class
p same(Sub.new("c")).class
p same(Sub.new("d")).equal?(Sub.new("d"))
s = Sub.new("e")
t = same(s)
t << "!"
p [s, t]
p same(Sub.new("\xff".b)).encoding
p copy(Named.new("f"))
p same(Named.new("g")).class
