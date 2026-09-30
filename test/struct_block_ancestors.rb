# a module included in a Struct.new block comes before one included by a
# later `class Name` reopening in #ancestors
module M; end
module N; end
S = Struct.new(:a) do
  include M
end
class S
  include N
end
p S.ancestors.take(4)
p S.include?(M)
p S.new(1).is_a?(N)
