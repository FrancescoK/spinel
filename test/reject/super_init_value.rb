# initialize is compiled to return nothing, so the value of `super` in a
# subclass's initialize, which CRuby answers with the parent's last value,
# is not there: `c = super` assigned a void call and the C did not build.
# It is refused at this line now (docs/limitations.md).
# spinel: reject-super-value
class N
  def initialize = (@a = [3, 1])
  def a = @a
end

class M < N
  def initialize
    c = super
    c << 4
  end
end
p M.new.a
