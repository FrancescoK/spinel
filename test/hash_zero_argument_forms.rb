# Hash#merge!, Hash#update, Hash#fetch_values and Array#fetch_values with no
# argument: merge! and update answer the receiver unchanged, fetch_values an
# empty Array.
def try(n)
  p [n, yield]
rescue Exception => e
  p [n, e.class]
end

h = { a: 1 }
try(:merge_bang) { r = h.merge!; [r.equal?(h), r, h] }
try(:update) { r = h.update; [r.equal?(h), r, h] }
try(:merge) { r = h.merge; [r.equal?(h), r] }
try(:merge_bang_block) { h.merge! { |k, a, b| a } }
try(:update_block) { h.update { |k, a, b| a } }
try(:chain) { h.merge!.merge!(b: 2) }
try(:chain_update) { h.update.update(c: 3) }
p h

s = { "k" => 1, "j" => 2 }
try(:str_merge) { s.merge! }
try(:str_update) { s.update }
i = { 1 => :x, 2 => :y }
try(:int_merge) { i.merge! }
m = { a: 1, "b" => 2.5, 3 => nil }
try(:mixed_merge) { m.merge! }
try(:mixed_update) { m.update }
try(:empty_merge) { {}.merge! }
try(:empty_update) { {}.update }
e = {}
e[:x] = 1
try(:built) { e.merge! }
try(:frozen_merge) { { a: 1 }.freeze.merge! }
try(:frozen_update) { { a: 1 }.freeze.update }
try(:frozen_empty) { {}.freeze.merge! }

class Box
  def initialize = @h = { k: :v }
  def h = @h
  def touch = @h.merge!
end
try(:ivar) { Box.new.touch }
try(:call) { Box.new.h.update }
LIVE = { a: 1 }
try(:const) { LIVE.merge!.equal?(LIVE) }
try(:arg) { [{ a: 1 }, { b: 2 }].map { |x| x.merge! } }
try(:poly) { [{ a: 1 }, 1][0].merge! }
try(:poly_block) { [{ a: 1 }, 1][0].merge! { |k, x, y| x } }
try(:poly_update) { [{ a: 1 }, 1][0].update }
try(:poly_update_block) { [{ a: 1 }, 1][0].update { |k, x, y| x } }
try(:poly_int) { [{ a: 1 }, 1][1].merge! }

# fetch_values with no key
try(:fv) { h.fetch_values }
try(:fv_block) { h.fetch_values { |k| k } }
try(:fv_str) { s.fetch_values }
try(:fv_int) { i.fetch_values }
try(:fv_mixed) { m.fetch_values }
try(:fv_empty) { {}.fetch_values }
try(:fv_with_key) { h.fetch_values(:a) }
try(:fv_miss) { h.fetch_values(:zz) }
try(:fv_miss_block) { h.fetch_values(:zz) { |k| k.to_s } }

a = [10, 20, 30]
try(:afv) { a.fetch_values }
try(:afv_block) { a.fetch_values { |x| x } }
try(:afv_str) { %w[a b].fetch_values }
try(:afv_float) { [1.5].fetch_values }
try(:afv_empty) { [].fetch_values }
try(:afv_empty_block) { [].fetch_values { |x| x } }
try(:afv_poly) { [[1, "a"], 1][0].fetch_values }
try(:afv_poly_block) { [[1, "a"], 1][0].fetch_values { |i| i } }
try(:fv_poly) { [{ a: 1 }, 1][0].fetch_values }
try(:afv_mixed) { [1, "a", :b].fetch_values }
try(:afv_with) { a.fetch_values(0, -1) }
try(:afv_miss) { a.fetch_values(5) }
try(:afv_miss_block) { a.fetch_values(5) { |x| x * 2 } }
try(:afv_nested) { [[1, 2], [3]].fetch_values }
log = []
try(:afv_order) { ((log << :recv; a)).fetch_values }
p log
log = []
try(:fv_order) { ((log << :recv; h)).fetch_values }
p log

# the receiver is evaluated once for merge! and update as well
log = []
try(:merge_order) { ((log << :recv; h)).merge! }
p log
log = []
try(:update_order) { ((log << :recv; h)).update }
p log

# a receiver that is nil at run time is a NoMethodError
class Holder
  attr_accessor :h

  def fill
    @h = { a: 1 }
  end
end
filled = Holder.new
filled.fill
unfilled = Holder.new
try(:nil_merge) { unfilled.h.merge! }
try(:nil_update) { unfilled.h.update }
try(:nil_fetch_values) { unfilled.h.fetch_values }

# an Array that is nil at run time, where a boxed Array is the other branch
def boxed_fetch_values(a = nil) = a.fetch_values
try(:nil_boxed_array) { boxed_fetch_values }
try(:boxed_array) { boxed_fetch_values([1, "a"]) }
try(:filled_merge) { filled.h.merge! }

# a call with a block on a receiver held in a value of several types, and the
# same call without one, meeting at one yield
def meet(n) = p([n, yield])
def plain(h) = h.merge!
def blocked(h) = h.merge! { |k, a, b| a }
meet(:plain) { plain({ a: 1 }) }
meet(:blocked_sym) { blocked({ a: 1 }) }
meet(:blocked_str) { blocked({ "a" => 1.5 }) }
