# A Float operand read off an array the loop caches (emit_nilfree_operand),
# through a field that may be nil, raises NoMethodError for `[]` when it is
# nil, as CRuby does: the read took the operand's own error, TypeError on
# the right of `+` and NoMethodError for `-` on the left. A nil index
# raises TypeError, after a nil receiver's NoMethodError.
class Ctx
  attr_accessor :resid

  def initialize
    @resid = nil
  end
end

def show(tag)
  r = yield
  puts "#{tag} #{r.inspect}"
rescue => e
  puts "#{tag} #{e.class}: #{e.message}"
end

def op_assign(ctx, n)
  s = 0.0
  j = 0
  while j < n
    s += ctx.resid[j]
    j += 1
  end
  s
end

def right(ctx, n)
  s = 0.0
  j = 0
  while j < n
    s = s + ctx.resid[j]
    j += 1
  end
  s
end

def left(ctx, n)
  s = 0.0
  j = 0
  while j < n
    s = ctx.resid[j] - s
    j += 1
  end
  s
end

def at(ctx, str, n)
  k = str.index("b")
  s = 0.0
  j = 0
  while j < n
    s += ctx.resid[k]
    j += 1
  end
  s
end

ctx = Ctx.new
show("op-assign nil") { op_assign(ctx, 2) }
show("right nil") { right(ctx, 2) }
show("left nil") { left(ctx, 2) }
show("nil, no pass") { op_assign(ctx, 0) }
show("nil, nil index") { at(ctx, "xyz", 2) }
ctx.resid = [0.5, 1.5]
show("filled") { [op_assign(ctx, 2), right(ctx, 2), left(ctx, 2)] }
show("past the end") { op_assign(ctx, 3) }
show("past the end, left") { left(ctx, 3) }
show("nil index") { at(ctx, "xyz", 2) }
show("index") { at(ctx, "abc", 2) }
