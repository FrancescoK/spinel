# spinel: reject-subclass: a define_method under a condition only the run time decides
class Outer
  S = Struct.new(:a) do
    define_method(:hi) { 1 } if [].size > 0
  end
end
p Outer::S.new(1).respond_to?(:hi)
