# A super call keeps the yield value after the parent has evaluated another expression.
class B
  def m(a, &b) = ([a, (b ? b.call : nil)]; yield)
end
class ProcSymbol < B
  def m
    blk = proc { :blk }
    [super(1, &blk), 0]
  end
end
class LiteralSymbol < B
  def m
    [super(1) { :blk }, 0]
  end
end
p ProcSymbol.new.m
p LiteralSymbol.new.m
class ProcInteger < B
  def m
    blk = proc { 17 }
    [super(1, &blk), 0]
  end
end
class LiteralInteger < B
  def m
    [super(1) { 17 }, 0]
  end
end
p ProcInteger.new.m
p LiteralInteger.new.m
class ProcNil < B
  def m
    blk = proc { nil }
    [super(1, &blk), 0]
  end
end
class LiteralNil < B
  def m
    [super(1) { nil }, 0]
  end
end
p ProcNil.new.m
p LiteralNil.new.m
class ProcArray < B
  def m
    blk = proc { [2, 3] }
    [super(1, &blk), 0]
  end
end
class LiteralArray < B
  def m
    [super(1) { [2, 3] }, 0]
  end
end
p ProcArray.new.m
p LiteralArray.new.m

# Both calls made by the parent still run when the block answers nil.
class Effects < B
  def m
    seen = []
    blk = proc { seen << :called; nil }
    [super(1, &blk), seen]
  end
end
p Effects.new.m

# An always-raising block has a dead result slot, but still raises.
class ProcRaise < B
  def m = [super(1, &proc { raise "proc" }), 0]
end
class LiteralRaise < B
  def m = [super(1) { raise "literal" }, 0]
end
begin
  ProcRaise.new.m
rescue RuntimeError => e
  p e.message
end
begin
  LiteralRaise.new.m
rescue RuntimeError => e
  p e.message
end
