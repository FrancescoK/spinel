# transform_values and transform_keys given a Proc, a lambda or a Method as a
# block argument call it for each value or key. Their emitter read such a
# block argument as an empty block, and every value became nil (#7554).
h = { "a" => "x", "b" => "y" }
p h.transform_values(&:upcase)
p h.transform_keys(&:upcase)
pr = proc { |v| v * 2 }
p h.transform_values(&pr)
p h.transform_keys(&pr)
lm = ->(v) { v + "!" }
p h.transform_values(&lm)
def twice(s) = s * 2
p h.transform_values(&method(:twice))
m = method(:twice)
p h.transform_keys(&m)
module Shout
  def self.call_it(s) = s.upcase + "!"
end
p h.transform_values(&Shout.method(:call_it))
def inside(h, f) = h.transform_values(&f)
p inside({ "k" => 3 }, ->(v) { v + 1 })
