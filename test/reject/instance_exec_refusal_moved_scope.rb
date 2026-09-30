# A refusal inside an instance_exec block abandons that unit, and the unit's
# class method used to stay moved to the block's receiver class: the later
# call of B.m was then not found and refused as well. Only ObjectSpace is
# refused here.
class A
  def m = "A#m"
end

class C
  def m = "C#m"
end

class B
  def self.m(o, xs)
    o.instance_exec { xs.map { |x| x.m }; ObjectSpace.each_object(Class) { } }
  end
end

xs = [A.new, C.new]
p B.m(A.new, xs)
