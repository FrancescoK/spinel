# A block whose last statement calls, without a block, a method that asks
# block_given?: that method is spliced, and the yield reading the block's
# value gets the spliced method's answer.

def items
  return nil if block_given?
  [1, "x"]
end

def items_if
  if block_given? then nil else [1, "x"] end
end

def name
  return nil if block_given?
  "n"
end

def flag
  return false if block_given?
  true
end

class Box
  def items
    return nil if block_given?
    [2, :y]
  end

  def each
    return to_enum(:each) unless block_given?
    yield 3
    yield 4
    self
  end
end

def show
  p yield
end

def keep
  v = yield
  p v
end

def cond
  if yield then p :yes else p :no end
end

def all
  p yield.to_a
end

show { items }
keep { items }
show { items_if }
show { name }
show { flag }
cond { flag }
show { Box.new.items }
all { b = Box.new; b.each }
show { items { } }
