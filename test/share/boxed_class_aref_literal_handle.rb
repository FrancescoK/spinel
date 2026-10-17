# A boxed receiver's `[]` that may be a Struct class (`P[...]`, its new) or
# a program class whose own `[]` keeps its arguments takes a String literal
# argument as the handle those arms are handed: the handle is made around
# the literal's bytes and read back as its String, where the temp declared
# for the handle was given the bytes and the C did not compile (campfire's
# `meta["charset"]` in the nokogiri package, beside its own Set[]).
P = Struct.new(:a)
class Bag
  def self.[](*items) = new(items)
  def initialize(items) = @items = items
  def items = @items
  def push(s) = @items << s
end
class Doc
  def initialize(m) = @m = m
  def at_xpath(q) = @m
  def meta_encoding
    meta = at_xpath("//meta")
    return meta["charset"] unless meta.nil?
    nil
  end
end
held = +"kept"
bag = Bag[held]
held << "!"
bag.items[0] << "?"
p bag.items, held
vals = [P, Bag, { "charset" => "utf-8" }, nil]
p Doc.new(vals[ARGV.size]).meta_encoding
p Doc.new(vals[ARGV.size + 1]).meta_encoding.items
p Doc.new(vals[ARGV.size + 2]).meta_encoding
p Doc.new(vals[3]).meta_encoding
