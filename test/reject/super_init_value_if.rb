# The value of `super` in initialize reaches `c` through a branch: the last
# statement of an if whose value is used is no statement whose value is
# thrown away (see super_init_value.rb).
# spinel: reject-super-value
class N
  def initialize = (@a = [3, 1])
  def a = @a
end

class M < N
  def initialize(flag)
    c = if flag
          super()
        else
          []
        end
    c << 4
  end
end
p M.new(true).a
