# A computed-name `send` in a superclass method dispatches on boxed self, whose
# arms include every class defining the candidate name. An unrelated class's
# method of that name has its arm dropped when its parameter's kind and the
# call's argument kind are two different concrete kinds and either is a
# builtin pointer kind: the other is then a different C struct or a scalar,
# and the C call would pass one where the other was expected. Covered here:
#   - an Exception into a Hash, Array, Proc or user-object-array parameter
#   - an Array into a Hash parameter, and a Hash into an Array parameter
# (the matching arm of the called class still runs). A pointer kind against
# a scalar is in dyn_send_arm_param_kind_scalar.rb.
class Foo
  def initialize(v) = @v = v
  def v = @v
end
class Other
  def create(attrs = {}) = attrs.size
  def pick(items = []) = items.size
  def run(cb) = cb.call
  def fill(h) = h.size
  def tally(foos) = foos.map { |f| f.v }.sum
  def total(list) = list.length
end
class Base
  def handle(name, error) = send(name, error)
  def handle_public(name, error) = public_send(name, error)
  def handle_list(name, list) = send(name, list)
  def handle_hash(name, h) = send(name, h)
end
class Child < Base
  def create = "created"
  def pick = "picked"
  def run = "ran"
  def oops(e) = "oops: #{e.message}"
  def fill(a) = a.length
  def tally = "tallied"
  def total(h) = h.size
end
p Other.new.create({ a: 1 })
p Other.new.pick([1, 2])
p Other.new.run(-> { 1 })
p Other.new.fill({ a: 1 })
p Child.new.create
p Child.new.pick
p Child.new.run
p Other.new.tally([Foo.new(1), Foo.new(2)])
p Other.new.total([1, 2])
p Child.new.tally
p Child.new.handle("oops".to_sym, StandardError.new("x"))
p Child.new.handle_public("oops".to_sym, StandardError.new("y"))
p Child.new.handle_list("fill".to_sym, [1, 2, 3])
p Child.new.handle_hash("total".to_sym, { a: 1, b: 2 })
