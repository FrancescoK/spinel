# transform_values! / transform_keys! is Hash's own: on a class deriving
# from Hash it changes the receiver without calling the class's replace or
# transform_values. They were spelled as `replace(transform_values { })`,
# which a Hash subclass answered with its own methods: rack's Headers,
# whose transform_values is `dup.transform_values!`, came back into it, and
# its replace handed the transformed copy to its update (whose parameter a
# plain Hash also reaches), so the program was refused.
class Headers < Hash
  def merge(hash, &block) = dup.merge!(hash, &block)

  def replace(hash)
    puts "own replace"
    clear
    update(hash)
  end

  def transform_values(&block) = dup.transform_values!(&block)
  def transform_keys(&block) = dup.transform_keys!(&block)

  def update(hash, &block)
    hash.each { |k, v| self[k] = v }
    self
  end
  alias merge! update
end

h = Headers.new
h["a"] = "1"
p h.merge("b" => "2")
t = h.transform_values(&:upcase)
p t, t.class, h
h.transform_values! { |v| v * 2 }
p h
p h.transform_keys(&:to_sym)
