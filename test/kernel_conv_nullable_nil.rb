class Opts
  def to_hash = {b: 2}
end
class SubOpts < Opts
end
class Named
  def to_hash = {"k" => 1}
end
class Lst
  def to_ary = [1, 2]
end
class Mixed
  def to_ary = [1, "two", :three]
end
class Lst2
  def to_a = [3]
end
class Txt
  def initialize(s) = (@s = s)
  def to_str = @s + "!"
end

def hh(x) = Hash(x)
def hs(x) = Hash(x)
def hn(x) = Hash(x)
def aa(x) = Array(x)
def am(x) = Array(x)
def a2(x) = Array(x)
def ss(x) = String(x)

p hh(Opts.new), hh(nil)
p hs(SubOpts.new), hs(nil)
p hn(Named.new), hn(nil).size
p aa(Lst.new), aa(nil)
p am(Mixed.new), am(nil)
p a2(Lst2.new), a2(nil)
p ss(Txt.new("t")), ss(nil), ss(nil).frozen?
p Hash(nil).merge(hh(nil)), Array(nil) + aa(nil)

class Holder
  def initialize = (@o = nil)
  def fill = (@o = Opts.new)
  def conv = Hash(@o)
end
h = Holder.new
p h.conv
h.fill
p h.conv

def only_obj(x) = Hash(x)
p only_obj(Opts.new)
