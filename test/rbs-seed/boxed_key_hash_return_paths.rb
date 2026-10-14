# A Hash[String, Integer] return seed gives way where the Hash a method
# answers has boxed keys (`{[s, 1][0] => 1}`, an sp_PolyPolyHash), but the
# paths of a method join into one type: an explicit return with boxed keys
# beside a body or another return with String keys joins to a plain boxed
# value, which hid the Hash from that test. The seed held, and the method's
# C returned the boxed-key Hash through a String-keyed return type. An
# explicit return with boxed keys now drops the seed, as a body with them
# does.
# spinel: rbs-seed-check
class BkhrBox
  def initialize(s)
    @s = s
  end

  def guard(f)
    return { @s => 1 } if f
    { "x" => 2 }
  end

  def two(f)
    return { @s => 1 } if f == 1
    return { @s => 3 } if f == 2
    { "x" => 2 }
  end

  def body(f)
    return { "x" => 2 } if f
    { @s => 1 }
  end

  def mixed(f)
    return { "x" => 2 } if f == 1
    return { @s => 3 } if f == 2
    { "y" => 4 }
  end
end

s = +"ab"
s << "1"
u = [s, 1][0]
b = BkhrBox.new(u)
p b.guard(true), b.guard(false)
p b.two(1), b.two(2), b.two(3)
p b.body(true), b.body(false)
p b.mixed(1), b.mixed(2), b.mixed(3)
