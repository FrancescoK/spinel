# A yielding method reached only through a block handed on as `&blk`
# (`capture(&block)` inside a block another method splices, or with a
# method that keeps its block as a proc): its `value = yield` takes the
# String the outermost block answers, and a tail that answers that
# String -- the variable, or through an is_a? guard its conversion, or a
# frozen literal -- hands the caller that String's handle.
class Store
  def initialize = @data = {}
  def self.copy(v) = v.is_a?(String) ? v.dup : v
  def write(k, v)
    @data[k] = Store.copy(v)
    true
  end
  def fetch(key)
    value = if @data.key?(key)
      Store.copy(@data[key])
    else
      computed = yield
      write(key, computed)
      computed
    end
    value
  end
end
module VH
  def self.capture
    value = yield
    value.is_a?(String) ? value.to_s : ""
  end
  def self.keep
    value = yield
    value
  end
end
S = Store.new
def cma(k, &block) = S.fetch(k) { VH.capture(&block) }
def kma(k, &block) = S.fetch(k) { VH.keep(&block) }
$caching = true
def cached(k, &block)
  if $caching
    nil
  else
    return VH.capture(&block)
  end
  S.fetch("k-#{k}") { VH.capture(&block) }
end

s = +"hi"
x = cma("a") { s }
x << "!"
p x, s
t = +"yo"
w = kma("b") { t }
w << "?"
p w, t
p cma("c") { 12 }
p cma("a") { +"cached" }

u = +"uu"
y = cached("a") { u }
y << "!"
p y, u
p cached("c") { 12 }
z = cached("a") { +"other" }
z << "?"
p z, u
l = cached("d") { "lit" }
p l, l.frozen?
pr = proc { u }
v = cached("e", &pr)
v << "#"
p v, u
$caching = false
q = cached("f") { u }
q << "%"
p q, u
