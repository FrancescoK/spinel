# `Class.new(Hash)` without a block makes its class at run time, and no
# class of the program's own stands for it, so it is refused where it is
# written; `class Registry < Hash` and the block form are supported.
# spinel: reject-subclass: Class.new(Hash) without a block is not supported yet
Registry = Class.new(Hash)
r = Registry.new
r[:a] = 1
p r.size
