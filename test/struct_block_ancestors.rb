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

# a plain class reopened with an explicit superclass keeps source order
module CM; end
module CN; end
class CC
  include CM
end
class CC < Object
  include CN
end
p CC.ancestors.take(3)
