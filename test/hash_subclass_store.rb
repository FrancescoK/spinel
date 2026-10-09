# A subclass of Hash is a Hash: `[]=` stores into it and `size` counts it.
class Registry < Hash
end

r = Registry.new
r[:a] = 1
p r.size
