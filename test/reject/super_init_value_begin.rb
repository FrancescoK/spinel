# The value of `super` in initialize reaches `c` through a begin: the last
# statement of a begin whose value is used is no statement whose value is
# thrown away (see super_init_value.rb).
# spinel: reject-super-value
class N
  def initialize = (@a = [3, 1])
  def a = @a
end

class M < N
  def initialize
    c = begin
          super
        end
    c << 4
  end
end
p M.new.a
