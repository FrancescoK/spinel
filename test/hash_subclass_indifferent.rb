# The shape of activesupport's HashWithIndifferentAccess: a Hash subclass
# beside a reopen of Hash, aliasing Hash's own []= and update before
# defining its own (the aliases keep naming Hash's), converting keys, and
# reaching Hash's methods through super with the caller's block and a
# splat of the rest.
class Hash
  def with_indifferent_access = IndifferentHash.new(self)
  def blank? = empty?
end

class IndifferentHash < Hash
  def initialize(constructor = nil)
    if constructor.respond_to?(:to_hash)
      super()
      update(constructor)
    else
      super()
    end
  end

  alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
  alias_method :regular_update, :update unless method_defined?(:regular_update)

  def []=(key, value)
    regular_writer(convert_key(key), value)
  end

  def update(*other_hashes, &block)
    other_hashes.each do |other|
      if other.is_a?(IndifferentHash)
        regular_update(other, &block)
      else
        other.to_hash.each_pair do |key, value|
          value = block.call(convert_key(key), self[key], value) if block && key?(key)
          regular_writer(convert_key(key), value)
        end
      end
    end
    self
  end
  alias_method :merge!, :update

  def [](key) = super(convert_key(key))
  def key?(key) = super(convert_key(key))
  def fetch(key, *extras) = super(convert_key(key), *extras)
  def delete(key) = super(convert_key(key))
  def values_at(*keys) = super(*keys.map { |k| convert_key(k) })
  def dup = self.class.new(self)
  def merge(*hashes, &block) = dup.update(*hashes, &block)
  def slice(*keys)
    keys.map! { |key| convert_key(key) }
    self.class.new(super)
  end
  def transform_keys(&block) = self.class.new(super(&block))
  def to_hash
    h = {}
    each_pair { |k, v| h[k] = v }
    h
  end

  def note = blank? ? "empty" : "full"

  private

  def convert_key(key) = key.is_a?(Symbol) ? key.name : key
end

h = IndifferentHash.new(a: 1, "b" => 2)
h[:c] = 3
p h, h.class
p h[:a], h["a"], h.key?(:b), h.fetch(:c), h.fetch(:zz, 0), h.fetch(:zz) { |k| k * 2 }
p h.values_at(:a, "c")
h.update(a: 10) { |k, o, n| o + n }
p h[:a]
m = h.merge(d: 4)
p m.class, m, h.size
p h.slice(:a, :b).class, h.slice(:a, :b)
p h.transform_keys(&:upcase).class
p h.delete(:b), h
w = {x: 1}.with_indifferent_access
p w.class, w[:x], w["x"], w.blank?, IndifferentHash.new.blank?
p h.to_hash.class, h.to_hash
p h.note, IndifferentHash.new.note
