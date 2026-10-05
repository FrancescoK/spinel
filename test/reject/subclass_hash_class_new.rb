# Class.new(Hash) without a block makes its class at run time, and no class
# of the program's own stands for it; `class Registry < Hash` is supported.
Registry = Class.new(Hash)
r = Registry.new
r[:a] = 1
p r.size
