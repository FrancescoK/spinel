# a safe-navigation call of a name a Hash also answers (slice), on a value
# that may be nil, a program object or another class: the Hash arm of the
# dispatch answers boxed

class Loc
  def initialize(s) = @s = s
  def slice = @s
end
class N
  def initialize(l) = @l = l
  def ml
    l = @l
    case l
    when nil then nil
    when Loc then l
    else @l = Loc.new("packed #{l}")
    end
  end
  def message = ml&.slice
end
p N.new(Loc.new("a")).message
p N.new(nil).message
p N.new(5).message
p N.new({ a: 1 }).message
