# An ivar's `{}` that String values are stored into and appended to through
# the hash: the appends make the values shared handles and the slot a
# poly-valued hash, so the literal builds that variant too (it was left as the
# String-valued default and the boxed store refused with a TypeError).
class Holder
  def initialize
    @fields = {}
    @fields["a"] = +""
    @fields["a"] << "x"
    puts @fields["a"]
  end
end
Holder.new

class Dup
  def initialize
    @fields = {}
    @fields["a"] = "".dup
    @fields["a"] << "x"
    puts @fields["a"]
  end
end
Dup.new

class ToS
  def initialize
    @fields = {}
    @fields["a"] = 42.to_s
    @fields["a"] << "x"
    puts @fields["a"]
  end
end
ToS.new

class Split
  def initialize
    @fields = {}
  end
  def set
    @fields["a"] = +""
  end
  def add
    @fields["a"] << "x"
  end
  def show
    puts @fields["a"]
  end
end
s = Split.new
s.set
s.add
s.show
