class NumberLike
  def to_int
    raise "unexpected conversion"
  end
end

def first(value) = value
def second(value) = value

def invoke(which, value)
  callable = which ? method(:first) : method(:second)
  callable.call(value)
end

p invoke(true, NumberLike.new).class
p invoke(false, Float::INFINITY)
p invoke(true, -Float::INFINITY)
p invoke(false, Float::NAN).nan?
p invoke(true, nil)
p invoke(false, 7)
p invoke(true, "text")
p invoke(false, [1, 2])
p invoke(true, { a: 3 })
p invoke(false, "9" * 80)
