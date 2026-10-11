# A class value's `superclass` stays refused beside a class whose superclass
# is an anonymous class, even when another class defines its own
# `self.superclass`: the switch over class methods leaves FromAnon on the
# builtin, which would answer Struct where CRuby answers the anonymous class.
class FromAnon < Struct.new(:a)
end

class Custom
  def self.superclass
    "custom-super"
  end
end

def sup(k)
  k.superclass
end

p sup(FromAnon)
