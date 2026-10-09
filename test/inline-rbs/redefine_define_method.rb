# An annotated def replaced by a define_method in the same class. The block is
# the method calls reach, and the annotation says nothing about it: it is
# reported, naming the define_method, and ignored whole.
class K
  #: (String) -> String
  def m(x) = x
  define_method(:m) { |x| x }
end

p K.new.m(1)
