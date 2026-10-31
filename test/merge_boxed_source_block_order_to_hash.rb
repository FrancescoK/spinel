# merge! with a conflict block into a general Hash whose source is boxed:
# a user object passed as the source is converted through its #to_hash
# first, as CRuby converts it, and the source argument is evaluated before
# the receiver's frozen check (its effect shows, then FrozenError).
class Pairs
  def initialize(h) = @h = h
  def to_hash = @h
end

def assign(obj, source)
  obj.merge!(source) { |_k, a, b| [a, b] }
  obj
end
p assign({ "a" => 1 }, { "a" => 2 })
p assign({ "a" => 1 }, Pairs.new({ "a" => 3, "b" => 4 }))

def noisy(log, h)
  log << :evaluated
  h
end

def assign_frozen(obj, log, source)
  obj.merge!(noisy(log, source)) { |_k, a, b| [a, b] }
  obj
end
log = []
p assign_frozen({ "c" => "x" }, [], { "c" => "y" })
p assign_frozen({ "c" => "x" }, [], Pairs.new({ "c" => "z" }))
begin
  assign_frozen({ "a" => 1 }.freeze, log, { "a" => 2 })
rescue FrozenError => e
  p e.class
end
p log
