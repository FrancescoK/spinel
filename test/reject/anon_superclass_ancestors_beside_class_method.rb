# The same for `ancestors`: another class's own `self.ancestors` does not
# answer for FromAnon, whose chain would leave out the anonymous class.
class FromAnon < Struct.new(:a)
end

class Custom
  def self.ancestors
    [:custom]
  end
end

def chain(k)
  k.ancestors
end

p chain(FromAnon).size
