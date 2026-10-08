# A subclass of Hash: `[]=` raised NoMethodError at run time (#7075).
# spinel: reject-subclass: class Registry < Hash: subclassing Hash is not supported yet
class Registry < Hash
end

r = Registry.new
r[:a] = 1
p r.size
