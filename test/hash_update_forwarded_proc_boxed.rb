# Hash#update of a Hash only the run time knows, with a block handed in as
# `&block` (nil when the caller gave none), on a Hash of boxed keys and
# values: the block resolves a key already there. The call raised
# NoMethodError.
def up(h, o, &block) = h.update(o, &block)
h = {"a" => 1, 2 => "x"}
o = [{"a" => 5, "b" => 2}, 1].first
up(h, o)
p h
up(h, [{"a" => 10}, 1].first) { |k, old, new| old + new }
p h
