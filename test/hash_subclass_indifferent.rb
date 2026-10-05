# ActiveSupport's HashWithIndifferentAccess, self-contained: a Hash subclass
# (#7449) whose [], []=, key?, fetch, delete and dig convert a Symbol key to
# its String through a private helper and `super(convert_key(key))`, whose
# update walks the other Hash with each_pair, whose merge is `dup.update`,
# and whose initialize takes a Hash or a default value. Its instances are
# Hashes: p, ==, is_a?, map and size are Hash's.
class HashWithIndifferentAccess < Hash
  def initialize(constructor = nil)
    if constructor.respond_to?(:to_hash)
      super()
      update(constructor)
    else
      super(constructor)
    end
  end

  def [](key)
    super(convert_key(key))
  end

  def []=(key, value)
    super(convert_key(key), convert_value(value))
  end
  alias_method :store, :[]=

  def update(other)
    other.each_pair { |key, value| self[key] = value }
    self
  end
  alias_method :merge!, :update

  def key?(key)
    super(convert_key(key))
  end
  alias_method :include?, :key?
  alias_method :has_key?, :key?

  def fetch(key, *extras)
    super(convert_key(key), *extras)
  end

  def delete(key)
    super(convert_key(key))
  end

  def dig(*args)
    args[0] = convert_key(args[0]) if args.size > 0
    super(*args)
  end

  def merge(other)
    dup.update(other)
  end

  def to_hash
    h = {}
    each_pair { |k, v| h[k] = v }
    h
  end

  def symbolize_keys
    h = {}
    each_pair { |k, v| h[k.to_sym] = v }
    h
  end

  private

  def convert_key(key)
    key.kind_of?(Symbol) ? key.name : key
  end

  def convert_value(value)
    value.is_a?(Hash) && !value.is_a?(HashWithIndifferentAccess) ? HashWithIndifferentAccess.new(value) : value
  end
end

h = HashWithIndifferentAccess.new
h[:a] = 1
h["b"] = 2
p h[:a], h["a"], h[:b], h["b"]
p h.key?(:a), h.include?("b"), h.has_key?(:zz)
p h.fetch(:a), h.fetch(:zz, 0)
p h
h2 = HashWithIndifferentAccess.new(c: 3, "d" => 4)
p h2, h2[:c], h2["d"]
m = h.merge(e: 5)
p m.class, m[:e], m["a"], h.key?(:e)
p h.delete(:a), h
d = HashWithIndifferentAccess.new(5)
p d[:missing], d.default
n = HashWithIndifferentAccess.new(x: {y: 1})
p n[:x].class, n[:x][:y]
p n.to_hash.class, h.symbolize_keys
c = h.dup
c[:z] = 26
p c.class, c, h
p h.is_a?(Hash), HashWithIndifferentAccess.ancestors.include?(Hash)
p h.map { |k, v| [k, v] }
p h.size, h.keys, h.values, h.empty?
