# Under --share-strings (#6765), an Array[String] parameter, reader or
# instance variable an --rbs signature types takes the boxed Array of
# shared handles when the Strings it holds are shared, as an inferred
# String Array does: the seed says what it holds, Strings, and not how C
# holds them. The rule refused each of these ("a typed String container
# cannot hold the shared handle yet"), and Roundhouse's selector class
# stopped at "--rbs seed contradicted".
class ShrbsaSelector
  def initialize(kind, excluded, keys, values, ops)
    @kind = kind
    @excluded = excluded
    @keys = keys
    @values = values
    @ops = ops
  end

  def kind = @kind
  def excluded = @excluded
  def keys = @keys
  def values = @values
  def ops = @ops

  def describe
    out = +""
    @keys.each_with_index { |k, i| out << k << @ops[i] << @values[i] << ";" }
    out
  end

  def self.not_names(text)
    text[5, text.length - 6].to_s.split(",")
  end

  def self.parse(text)
    return new("all", [], [], [], []) if text == "*"
    return new("not", not_names(text), [], [], []) if text.start_with?(":not(")
    keys = []
    values = []
    ops = []
    text.split(",").each do |pair|
      eq = pair.index("=")
      keys << pair[0, eq].to_s
      values << pair[eq + 1, pair.length].to_s
      ops << "="
    end
    new("name", [], keys, values, ops)
  end
end

class ShrbsaPinned
  def initialize(keys)
    @keys = keys
  end

  def keys = @keys
end

def shrbsa_join(keys)
  keys.join("+")
end

s = ShrbsaSelector.parse("href=x,id=y")
s.keys.each { |k| k << "!" }
s.values[0] << "?"
p s.kind, s.keys, s.values, s.ops, s.excluded
puts s.describe
t = ShrbsaSelector.parse(":not(p,q)")
p t.kind, t.excluded
p ShrbsaSelector.parse("*").keys

ks = s.keys
pin = ShrbsaPinned.new(ks)
ks[1] << "?"
p pin.keys
puts shrbsa_join(ks)
