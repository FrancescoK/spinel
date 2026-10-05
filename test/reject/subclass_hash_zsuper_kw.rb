# A bare `super` into Hash from a method with keyword parameters: the
# arguments it would pass on are not spelled out yet.
class Registry < Hash
  def fetch(key, strict: false)
    super
  end
end
r = Registry.new
r[:a] = 1
p r.fetch(:a)
